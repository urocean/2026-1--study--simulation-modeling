using DrWatson
@quickactivate "project"
using Agents, DataFrames, Plots
using JLD2

include(srcdir("sir_model.jl"))

# Параметры эксперимента
params = Dict(
    :Ns => [1000, 1000, 1000],
    :β_und => [0.3, 0.4, 0.7],
    :β_det => [0.03, 0.04, 0.07],
    :infection_period => 14,
    :detection_time => 7,
    :death_rate => 0.02,
    :reinfection_probability => 0.1,
    :Is => [0, 0, 1],
    :seed => 42,
    :n_steps => 100,
)

# Инициализация модели
model = initialize_sir(; params...)

# Подготовка массивов для хранения данных
times = Int[]
S_vals = Int[]
I_vals = Int[]
R_vals = Int[]
total_vals = Int[]

# Запуск симуляции вручную
for step = 1:params[:n_steps]
    Agents.step!(model, 1)

    push!(times, step)
    push!(S_vals, susceptible_count(model))
    push!(I_vals, infected_count(model))
    push!(R_vals, recovered_count(model))
    push!(total_vals, total_count(model))
end

# Создаём DataFrame для удобства (опционально)
agent_df =
    DataFrame(time = times, susceptible = S_vals, infected = I_vals, recovered = R_vals)
model_df = DataFrame(time = times, total = total_vals)

# Визуализация
plot(
    agent_df.time,
    agent_df.susceptible,
    label = "Восприимчивые",
    xlabel = "Дни",
    ylabel = "Количество",
)
plot!(agent_df.time, agent_df.infected, label = "Инфицированные")
plot!(agent_df.time, agent_df.recovered, label = "Выздоровевшие")
plot!(agent_df.time, model_df.total, label = "Всего (включая умерших)", linestyle = :dash)
savefig(plotsdir("sir_basic_dynamics.png"))

# Сохранение данных
@save datadir("sir_basic_agent.jld2") agent_df
@save datadir("sir_basic_model.jld2") model_df

city_I = [[], [], []]

for step = 1:params[:n_steps]
    Agents.step!(model, 1)
    for city in 1:3
        agents_in_city = [a for a in allagents(model) if a.pos == city]
        infected = count(a.status == :I for a in agents_in_city)
        push!(city_I[city], infected)
    end
end

for city in 1:3
    println("Город $city пик = $(maximum(city_I[city]))")
end

plot(1:100, city_I[1], label="Город 1 β=0.3")
plot!(1:100, city_I[2], label="Город 2 β=0.4")
plot!(1:100, city_I[3], label="Город 3 β=0.7")
savefig(plotsdir("heterogeneity.png"))
