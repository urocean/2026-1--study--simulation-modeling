## add_packages.jl

using Pkg
Pkg.activate(".")  # Активируем текущий проект

## ОСНОВНЫЕ ПАКЕТЫ ДЛЯ РАБОТЫ
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

println("Установка базовых пакетов...")
Pkg.add(packages)
