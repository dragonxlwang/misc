
import __main__

# Returns a dict that survives over re-sourcing of this file. Used to hold
# per-vim session state
def local_state():
    if not hasattr(__main__, '__vimfb_local_state'):
        __main__.__vimfb_local_state = {}

    return __main__.__vimfb_local_state

# simple memo-izing mechanism. Call with key and a callable. If key has cached
# result, that will be returned. Otherwise, function will be called.
def cache(key, func):
    cache_data = local_state().setdefault('cache_data', {})

    if not cache_data.has_key(key):
        cache_data[key] = func()
    return cache_data[key]
