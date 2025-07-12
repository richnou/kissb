package require kissb.verilator
package require kissb.verilator.local 5.032

puts "Linting"

#verilator.runtime.local
verilator.verilate --version
verilator.lint [eda.f.substitute counter.f]