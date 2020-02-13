#!/usr/bin/env python2
import vim
from fbvimutils import vimfunc, vc

import threading
import queue as Queue
import time

# search_func is a function that takes three arguemnts
#     query: string being searched for
#     cache: an dict that gets passed in with each query.
#            Up to the search function to fill it with cache data.
#     force: ?
#
# Each call of search_func should return a list of results. Each result is a 4-tuple
#     display_string: value displayed in output
#     extra_string: extra contextual information displayed in typeahead
#     context: context variable passed to select_func when user selects a result
#     score: not used?

def key_val(keyspec):
    return vim.eval('"\%s"' % (keyspec))

class Typeahead:

    def __init__(self, search_func, select_func, prompt):
        self.current_winnr = 0
        self.selected_item = 0
        self.search_output = []
        self.selected = False
        self.force = False
        self.offset = 0
        self.prompt = prompt
        self.input_line = ''
        self.win_size = 8
        self.result_cache = {}
        self.stop = False
        self.search_func = search_func
        self.select_func = select_func
        self.input_loop = InputPollLoop(self.charCallback)
        self.search_queue = Queue.Queue()

    def charCallback(self, char):
        self.processChar(char)
        if not self.stop:
            self.refreshTypeaheadBuffer()

    def setup(self):
        # Get all our key sequences
        self.key_ctrl_c = key_val('<C-c>')
        self.key_esc = key_val('<esc>')
        self.key_bs = key_val('<bs>')
        self.key_ctrl_h = key_val('<C-h>')
        self.key_ctrl_j = key_val('<C-j>')
        self.key_ctrl_k = key_val('<C-k>')
        self.key_ctrl_n = key_val('<C-n>')
        self.key_ctrl_p = key_val('<C-p>')
        self.key_up = key_val('<Up>')
        self.key_down = key_val('<Down>')
        self.key_enter = key_val('<cr>')
        self.key_tab = key_val('<tab>')
        self.key_left = key_val('<Left>')
        self.key_right = key_val('<Right>')

    def setupWindow(self):
        # save current window
        self.current_winnr = vim.bindeval('winnr()')

        # setup our typeahead buffer
        vc('botright 1new "File Search"',
            'setlocal buftype=nofile',
            'nohlsearch',
            'setlocal noswapfile winfixheight',
            'setlocal nocursorcolumn',
            'setlocal nocursorline',
            'setlocal nonumber',
            'setlocal nowrap',
            'setlocal bufhidden=wipe',
            'resize %s' % (self.win_size),
            'normal "10oggzt"'
        )

    def refreshTypeaheadBuffer(self):
        new_contents = [self.prompt + '>> ' + self.input_line]
        displayed_entries = self.search_output[
          self.offset :
          self.offset + min(len(self.search_output) - self.offset, self.win_size-1)
        ]
        # find the longest value so that we can align the extra data
        max_val_len = reduce(max, [len(val) for val, _, _, _ in displayed_entries], 0)
        display_str = '%-' + str(max_val_len) + 's'
        for i in range(len(displayed_entries)):
            val, extra, _, _ = displayed_entries[i]
            entry = display_str % (val)
            if extra:
                entry += ' | ' + extra
            else:
                entry = entry.rstrip()
            if i == self.selected_item:
                new_contents.append(' * ' + entry)
            else:
                new_contents.append('   ' + entry)
        vim.current.buffer[:] = new_contents
        vc('redraw')

    def _stop(self):
        self.input_loop.stop()

    def _selected(self):
        self.selected = True
        self.input_loop.stop()

    def _setInputLine(self, input_line):
        self.input_line = input_line
        self.search_queue.put(input_line)

    def _searchWorker(self):
        while True:
            query = self.search_queue.get()
            while not self.search_queue.empty():
                query = self.search_queue.get()
            output = self.search_func(query, self.result_cache, False)
            self.input_loop.queueCallback(lambda: self.updateOutput(output))

    def updateOutput(self, output):
        self.search_output = output
        self.refreshTypeaheadBuffer()

    def processChar(self, char):
        if type(char) == type(1):
            char = vim.eval('nr2char(%s)' %(char))

        if char == self.key_esc or char == self.key_ctrl_c:
            self._stop()
            return
        elif char == self.key_up or char == self.key_ctrl_k or char == self.key_ctrl_p:
            selected_index = self.offset + self.selected_item
            if selected_index == 0:
                return

            if self.offset == 0:
                self.selected_item -= 1
                return

            if self.selected_item >= 3:
                self.selected_item -= 1
            else:
                self.offset -= 1
        elif char == self.key_down or char == self.key_ctrl_j or char == self.key_ctrl_n:
            selected_index = self.offset + self.selected_item
            remaining_from_offset = len(self.search_output) - self.offset
            lines_below_cursor = self.win_size - self.selected_item - 2

            if selected_index == len(self.search_output) - 1:
                return

            if remaining_from_offset <= 5:
                self.selected_item += 1
                return

            if lines_below_cursor >= 3:
                self.selected_item += 1
            else:
                self.offset += 1
        elif char == self.key_bs or char == self.key_ctrl_h:
            self.selected_item = 0
            self._setInputLine(self.input_line[:-1])
        elif char == self.key_enter:
            self._selected()
            return
        elif char == self.key_tab:
            self.force = True
        elif char == self.key_left or char == self.key_right:
            return
        else:
            self.selected_item = 0
            self.offset = 0
            self._setInputLine(self.input_line + char)

    def teardownWindow(self):
        vc('bdelete!')
        # restore window
        vc('%swincmd w' % (self.current_winnr))

    def run(self):
        self.setup()
        self.setupWindow()

        self.refreshTypeaheadBuffer()

        search_thread = threading.Thread(target=self._searchWorker)
        search_thread.daemon=True
        search_thread.start()

        self.input_loop.run()


        self.teardownWindow()
        if self.selected and self.search_output:
            self.select_func(self.search_output[self.offset + self.selected_item])

    def setPrompt(self, prompt):
        self.prompt = prompt
        self.refreshTypeaheadBuffer()

class InputPollLoop:

    def __init__(self, char_input_callback):
        self.thunkQueue = Queue.Queue()
        self.stopped = False
        self.charCallback = char_input_callback

    def queueCallback(self, callback):
        self.thunkQueue.put(callback)

    def stop(self):
        self.stopped = True

    def run(self):
        while not self.stopped:
            try:
                available = vim.bindeval('getchar(1)')
                if available == 0:
                    try:
                        callback = self.thunkQueue.get(False)
                        callback()
                    except Queue.Empty:
                        time.sleep(0.01)
                else:
                        char = vim.bindeval('getchar()')
                        self.charCallback(char)
            except KeyboardInterrupt:
                self.charCallback(key_val('<C-c>'))
