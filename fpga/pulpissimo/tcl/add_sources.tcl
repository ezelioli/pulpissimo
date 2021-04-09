# Check if we are using bender for ip management. If so, use the bender generated script that does everything
# Otherwise, source the individual tcl scripts generated by IPApprox.
if {[info exists ::env(BENDER)] && $::env(BENDER) == 1 } {
    source ../pulpissimo/tcl/generated/compile.tcl
} else {
    # set up includes
    source ../pulpissimo/tcl/generated/ips_inc_dirs.tcl
    set_property include_dirs $INCLUDE_DIRS [current_fileset]
    set_property include_dirs $INCLUDE_DIRS [current_fileset -simset]

    # setup and add IP source files
    source ../pulpissimo/tcl/generated/ips_src_files.tcl
    source ../pulpissimo/tcl/generated/ips_add_files.tcl

    # setup and add RTL source files
    source ../pulpissimo/tcl/generated/rtl_src_files.tcl
    source ../pulpissimo/tcl/generated/rtl_add_files.tcl
}