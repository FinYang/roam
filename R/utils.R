trace_call <- function(x, start_env = parent.frame()) {
  e <- environment(eval(x, env = start_env))
  if (isNamespace(e)) {
    getNamespaceName(e)
  } else {
    NULL
  }
}
