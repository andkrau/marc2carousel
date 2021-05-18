encoding system utf-8
set start [clock seconds]

proc  quit {} {
    after 10000
    exit
}

if {[file exists "template.html"] == 0 } {
    puts "Template file missing!"
    quit
}

if { $argc != 1 } {
    puts "You must provide the file name of the MARC file to open!"
    quit
}

set marcFile [lindex $argv 0]

proc getCover {marc} {
    set num 1
    set cover ""
    while {[dict exists $marc 856u${num}]} {
        if {[dict exists $marc 856-${num}] && [dict get $marc 856-${num}] == "42"} {
            set cover [dict get $marc 856u${num}]
        }
        incr num
    }
    return $cover
}

proc getLink {marc} {
    set num 1
    set link ""
    while {[dict exists $marc 856u${num}]} {
        if {[dict exists $marc 856-${num}] && [dict get $marc 856-${num}] == "40"} {
            set link [dict get $marc 856u${num}]
        }
        incr num
    }
    return $link
}

proc getTitle {marc} {
    set title ""
    if {[dict exists $marc 000-1] && [string index [dict get $marc 000-1] 5] != "d" && [dict exists $marc 245a1]} {
        set title [dict get $marc 245a1]
     }
    return $title
}

set found 0
set currentFile [open $marcFile r]
set allData [read $currentFile]
close $currentFile
set allData [split $allData "\x1D"]
set results ""
foreach record $allData {
    set record [split $record "\x1E"]
    set marc [dict create]
    set index {}
    set leader [string range [lindex $record 0] 0 23]
    dict set marc 000-1 $leader
    foreach {a b c d e f g h i j k l} [split [string range [lindex $record 0] 24 end] {}] {
        lappend index "$a$b$c$d$e$f$g$h$i$j$k$l"
    }
    set entries [lrange $record 1 end]
    set i 0
    set num 1
    while {$i < [llength $index]} {
        set link ""
        set image ""
        set title ""
        set tag [string range [lindex $index $i] 0 2]
        #puts "$tag [lindex $entries $i]"
        set entry [split [lindex $entries $i] "\x1F"]
        set entry [lreplace $entry 0 0 "-[lindex $entry 0]"]
        foreach sub $entry {
            if {[string length $sub] > 0} {
                set code [string range $sub 0 0]
                set data [string range $sub 1 end]
                if {[dict exists $marc ${tag}-${num}] == 1 && (${code} == "-")} {
                    incr num
                } elseif {${code} == "-"} {
                    set num 1
                }
                dict set marc ${tag}${code}${num} $data
                #puts "${tag}${code}${num} $data"
            }
        }
        incr i
    }
    set link [getLink $marc]
    set cover [getCover $marc]
    set title [getTitle $marc]
    #puts "$link ! $cover ! $title"
    if {[string length $link] > 10 && [string length $cover] > 10  && [string length $title] > 1} {
        incr found
        append results "<div><a href='${link}' target='_parent'><img height='200' data-lazy='${cover}' title='${title}'></a></div>"
    }
}
set carousel [open results.html w]
fconfigure $carousel -encoding utf-8
set templateFile [open template.html r]
set template_data [read $templateFile]
close $templateFile
set result_data [string map [list !MARC2CAROUSEL! "$results"] $template_data]
puts $carousel $result_data
close $carousel
puts "$found titles with covers and urls found!"
quit
