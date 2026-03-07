##!/usr/bin/env julia
## test_setup.jl

using DrWatson
@quickactivate "project"

println("✅ Проект активирован: ", projectdir())

## Проверка пакетов
packages = [
    "DifferentialEquations",
    "SimpleDiffEq",
    "Tables",
    "DataFrames",
    "StatsPlots",
    "LaTeXStrings", 
    "Plots",
    "BenchmarkTools",
    "Statistics",
    "FFTW"
]

println("\nПроверка пакетов:")
for pkg in packages
    try
        eval(Meta.parse("using $pkg"))
        println("  ✓ $pkg")
    catch e
        println("  ✗ $pkg: Ошибка загрузки")
    end
end

## Проверка путей
println("\nСтруктура проекта:")
println("  Корень:        ", projectdir())
println("  Данные:        ", datadir())
println("  Скрипты:       ", srcdir())
println("  Графики:       ", plotsdir())
