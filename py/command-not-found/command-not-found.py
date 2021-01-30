#!/usr/bin/python3
# (c) Zygmunt Krynicki, modified by Artemis for use in internal systems

from __future__ import absolute_import, print_function


__version__ = "0.3"
BUG_REPORT_URL = "https://bugs.launchpad.net/command-not-found/+filebug"

try:
    import sys
    if sys.path and sys.path[0] == '/usr/lib':
        # Avoid ImportError noise due to odd installation location.
        sys.path.pop(0)
    if sys.version < '3':
        # We might end up being executed with Python 2 due to an old
        # /etc/bash.bashrc.
        import os
        if "COMMAND_NOT_FOUND_FORCE_PYTHON2" not in os.environ:
            os.execvp("/usr/bin/python3", [sys.argv[0]] + sys.argv)

    import gettext
    import locale
    from optparse import OptionParser

    from CommandNotFound.util import crash_guard
    from CommandNotFound import CommandNotFound
except KeyboardInterrupt:
    import sys
    sys.exit(127)


def enable_i18n():
    cnf = gettext.translation("command-not-found", fallback=True)
    kwargs = {}
    if sys.version < '3':
        kwargs["unicode"] = True
    cnf.install(**kwargs)
    try:
        locale.setlocale(locale.LC_ALL, '')
    except locale.Error:
        locale.setlocale(locale.LC_ALL, 'C')


def fix_sys_argv(encoding=None):
    """
    Fix sys.argv to have only unicode strings, not binary strings.
    This is required by various places where such argument might be
    automatically coerced to unicode string for formatting
    """
    if encoding is None:
        encoding = locale.getpreferredencoding()
    sys.argv = [arg.decode(encoding) for arg in sys.argv]


class LocaleOptionParser(OptionParser):
    """
    OptionParser is broken as its implementation of _get_encoding() uses
    sys.getdefaultencoding() which is ascii, what it should be using is
    locale.getpreferredencoding() which returns value based on LC_CTYPE (most
    likely) and allows for UTF-8 encoding to be used.
    """
    def _get_encoding(self, file):
        encoding = getattr(file, "encoding", None)
        if not encoding:
            encoding = locale.getpreferredencoding()
        return encoding


def main():
    enable_i18n()
    if sys.version < '3':
        fix_sys_argv()
    parser = LocaleOptionParser(
        version=__version__,
        usage=_("%prog [options] <command-name>"))
    parser.add_option('-d', '--data-dir', action='store',
                      default="/usr/share/command-not-found",
                      help=_("use this path to locate data fields"))
    parser.add_option('--ignore-installed', '--ignore-installed',
                      action='store_true',  default=False,
                      help=_("ignore local binaries and display the available packages"))
    parser.add_option('--no-failure-msg',
                      action='store_true', default=False,
                      help=_("don't print '<command-name>: command not found'"))
    (options, args) = parser.parse_args()
    if len(args) == 1:
        try:
            cnf = CommandNotFound.CommandNotFound(options.data_dir)
        except FileNotFoundError:
            print(_("Artemis Shell command database is outdated/empty. Run 'sudo apt update' to refresh the database."), file=sys.stderr)
            print(_("%s: command not in Artemis Shell") % args[0], file=sys.stderr)
            return
        if not cnf.advise(args[0], options.ignore_installed) and not options.no_failure_msg:
            print(_("%s: command not in Artemis Shell") % args[0], file=sys.stderr)


if __name__ == "__main__":
    crash_guard(main, BUG_REPORT_URL, __version__)
