import localstate
import vim

# Hacktastic! a generic way to call vim functions. use vim.bindeval to populate
# an arg list in vim variable space, then vim.eval to call a func using
# transferred variables. The xfer is probably slow
def vimfunc(funcname, *args):
    countermap = localstate.cache('vimfunc_countermap', lambda: {})
    counter = countermap.setdefault('count', 0)
    countermap['count'] = counter + 1

    vim_arg_list_name = 'g:__vimfunc__arg_map_' + str(counter)
    vc('let %s = []' % (vim_arg_list_name))
    arg_list = vim.bindeval(vim_arg_list_name)
    arg_list.extend(args)

    arg_expr = ', '.join(['%s[%s]' %(vim_arg_list_name, i) for i in range(len(args))])
    expr = '%s(%s)' % (funcname, arg_expr)

    vim.eval(expr)

    vc('unlet %s' % (vim_arg_list_name))

# short hand for executing a list of vim commands provided as a list of string
# arguments
def vc(*ls):
    for c in ls:
        vim.command(c)


def log(logstr):
    f = open('/home/ken/fbvim.log', 'a')
    f.write(logstr + '\n')
    f.close()
