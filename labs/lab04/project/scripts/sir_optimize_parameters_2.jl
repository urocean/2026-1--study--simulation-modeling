using DrWatson
@quickactivate "project"

using BlackBoxOptim, Random, Statistics

include(srcdir("sir_model.jl"))

# Целевая функция: минимизируем пиковую заболеваемость и смертность
function cost_constrained(x)
    β_und = x[1]
    detection_time = round(Int, x[2])
    death_rate = x[3]
    
    peak_vals = []
    death_vals = []
    
    for rep in 1:3
        model = initialize_sir(
            Ns=[1000,1000,1000],
            β_und=fill(β_und, 3),
            β_det=fill(β_und/10, 3),
            infection_period=14,
            detection_time=detection_time,
            death_rate=death_rate,
            reinfection_probability=0.1,
            Is=[0,0,1],
            seed=42+rep
        )
        
        peak = 0.0
        for step in 1:100
            Agents.step!(model, 1)
            infected_frac = count(a.status == :I for a in allagents(model)) / nagents(model)
            peak = max(peak, infected_frac)
        end
        
        push!(peak_vals, peak)
        push!(death_vals, (3000 - nagents(model)) / 3000)
    end
    
    mean_peak = mean(peak_vals)
    mean_deaths = mean(death_vals)
    
    if mean_peak > 0.3
        return mean_deaths + 10 * (mean_peak - 0.3)
    else
        return mean_deaths
    end
end

result = bboptimize(cost_constrained, SearchRange=[(0.1,1.0),(3.0,14.0),(0.01,0.1)], NumDimensions=3, MaxTime=60)
best = best_candidate(result)
println("Оптимальные параметры: β=$(best[1]), время выявления=$(round(Int,best[2])), смертность=$(best[3])")
