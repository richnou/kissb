# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.xml 1.0


namespace eval ::kiss::xml {


        set level 0

        kissb.extension xml {


            toFileWriter content {

                set closed true
                foreach {key val} $content {

                    set isAttr false
                    if {[string index $key 0]=="@"} {

                        # Attr
                        set isAttr true
                        set key [string range $key 1 end]
                        files.writer.print "$key=\"$val\""

                        set closed false

                    } else {

                        # new value, close current element
                        if {${::kiss::xml::level}>0} {
                            files.writer.print ">"
                            files.writer.indent
                            set closed true
                        }

                        # Element
                        if {[llength $val]==1} {
                            files.writer.printLine <$key>$val</$key>
                        } else {
                            files.writer.print <$key
                            #files.writer.indent
                            try {
                                incr ::kiss::xml::level

                                xml.toFileWriter $val
                            } finally {
                                files.writer.outdent
                                files.writer.printLine </$key>
                                incr ::kiss::xml::level -1
                            }
                        }
                    }
                }

                # Close element if not closed
                if {!$closed} {
                    files.writer.print ">"
                }
            }

        }


}
