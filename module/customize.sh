SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=true

print_modname() {
  ui_print "*******************************"
  ui_print "      Universal Storage Fix"
  ui_print "*******************************"
}

on_install() {
  ui_print "Installing safety-first diagnostics engine"
  ui_print "No system storage permissions or mounts are changed."
}

set_permissions() {
  set_perm_recursive "$MODPATH" 0 0 0755 0644
  set_perm "$MODPATH/service.sh" 0 0 0755
  set_perm "$MODPATH/action.sh" 0 0 0755
  set_perm "$MODPATH/lib/usf.sh" 0 0 0755
}
