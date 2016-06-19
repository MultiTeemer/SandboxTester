module Signals
  SIGHUP = 'hangup'
  SIGINT = 'interrupt'
  SIGQUIT = 'quit'
  SIGILL = 'illegal instruction'
  SIGABRT = 'abort'
  SIGFPE = 'SIGFPE (floating point exception)'
  SIGKILL = 'kill'
  SIGBUS = 'bus error'
  SIGSEGV = 'SIGSEGV (segmentation violation)'
  SIGTERM = 'software termination signal from kill'
  SIGSYS = 'SIGSYS (bad argument to system call)'
  SIGXCPU =  'exceeded CPU time limit'
  SIGXFSZ = 'exceeded file size limit'
  SIGPWR = '30 (unknown signal number, run kill -l to list)'
end
module ExitStatus
  EXIT_SUCCESS = '0'
  EXIT_FAILURE = '1'
end
