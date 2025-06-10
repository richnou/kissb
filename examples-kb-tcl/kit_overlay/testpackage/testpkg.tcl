package provide kissb.testpackage 1.0
package require kissb 

puts "Loading testpackage..."

namespace eval testpackage {

    kissb.extension testpackage {

        hi args {

            puts "Hello from pkg..."
        }
    }

}