# SPDX-FileCopyrightText: 2024 KISSB
#
# SPDX-License-Identifier: Apache-2.0

package provide kissb.core.refresh 1.0


namespace eval kissb::refresh {

    kissb.extension refresh {

        is name {
            if {[env.isDefined KB_REFRESH_[string toupper $name]] || [env.isDefined KB_REFRESH_ALL] } {
                return true
            } else {
                return false
            }
        }

        isExact name {
            if {[env.isDefined KB_REFRESH_[string toupper $name]] } {
                return true
            } else {
                return false
            }
        }

        with {name script} {
            if {[refresh.is $name]} {
                uplevel [list eval $script]
            }
        }

        withExact {name script} {
            if {[refresh.isExact $name]} {
                uplevel [list eval $script]
            }
        }
    }
}
