# diameter unit: m (not mm)

# 標準無次元掃流力

function calc_non_dimensional_shear_stress(
    uₛ::T,
    specific_gravity::T,
    gravity_accel::T,
    diameter::T    
    ) where {T<:AbstractFloat}

    τₛ = (uₛ^2) / specific_gravity / gravity_accel / diameter

    return τₛ
end

function calc_non_dimensional_shear_stress(
    area::T,
    width::T,
    discharge::T,
    manning_n::T,
    specific_gravity::T,
    gravity_accel::T,
    diameter::T
    ) where {T<:AbstractFloat}

    uₛ = calc_friction_velocity(
        area,
        width,
        discharge,
        manning_n,
        gravity_accel
       )


    τₛ = calc_non_dimensional_shear_stress(
        uₛ,
        specific_gravity,
        gravity_accel,
        diameter    
    )

    return τₛ
end

function calc_non_dimensional_shear_stress(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    mean_diameter =
        average_neighbors_target_hour(
            ParticleSize.get_average_simulated_particle_size_dist(
                df,
                sediment_size,
                target_hour
            )
        ) ./ 1000

    τₛ = calc_non_dimensional_shear_stress.(
        area,
        width,
        discharge,
        param.manning_n,
        param.specific_gravity,
        param.g,
        mean_diameter    
    )
    
    return τₛ
end

"""
任意の粒径における（通常）無次元掃流力を求める
"""
function calc_non_dimensional_shear_stress(
    df::DataFrames.DataFrame,
    param::Param,
    target_hour::Int,
    diameter_m::AbstractFloat
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    τₛ = calc_non_dimensional_shear_stress.(
        area,
        width,
        discharge,
        param.manning_n,
        param.specific_gravity,
        param.g,
        diameter_m    
    )
    
    return τₛ
end

"""
特定年の（通常）無次元掃流力の平均値を求める。
"""
function calc_non_dimensional_shear_stress_yearly_mean(
    df::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year::Int,
    diameter_m::AbstractFloat
    )

    τₛ = calc_non_dimensional_shear_stress(
        df,
        param,
        each_year_timing.dict[year][1],
        diameter_m
    )

    
    for target_hour in (each_year_timing.dict[year][1]+1):each_year_timing.dict[year][2]

        τₛ .= τₛ .+ calc_non_dimensional_shear_stress(
            df,
            param,
            target_hour,
            diameter_m
        )

    end

    τₛ .= τₛ ./ (each_year_timing.dict[year][2] - each_year_timing.dict[year][1] + 1)

    return τₛ
end

"""
複数年の（通常）無次元掃流力の年平均値を求める。
"""
function calc_non_dimensional_shear_stress_yearly_mean(
    df::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    diameter_m::AbstractFloat
    )

    τₛ = calc_non_dimensional_shear_stress_yearly_mean(
        df,
        param,
        each_year_timing,
        year_first,
        diameter_m
    )

    for year in (year_first + 1):year_last

        τₛ .= τₛ .+ calc_non_dimensional_shear_stress_yearly_mean(
            df,
            param,
            each_year_timing,
            year,
            diameter_m
        )

    end

    τₛ .= τₛ ./ (year_last - year_first + 1)

    return τₛ
end

# 有効無次元掃流力

function calc_effective_non_dimensional_shear_stress(
    area::T,
    width::T,
    discharge::T,
    manning_n::T,
    specific_gravity::T,
    gravity_accel::T,
    mean_diameter::T,
    spec_diameter::T
    ) where {T<:AbstractFloat}

    uₑₘ = calc_effective_friction_velocity(
        discharge,
        area,
        area / width,
        mean_diameter,
        width,
        manning_n,
        specific_gravity,
        gravity_accel
    )

    τₑᵢ = calc_non_dimensional_shear_stress(
        uₑₘ,
        specific_gravity,
        gravity_accel,
        spec_diameter    
    )

    return τₑᵢ
end

function calc_effective_non_dimensional_shear_stress(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    target_hour::Int,
    spec_diameter::AbstractFloat
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    mean_diameter =
        average_neighbors_target_hour(
            ParticleSize.get_average_simulated_particle_size_dist(
                df,
                sediment_size,
                target_hour
            )
        ) ./ 1000

    τₑᵢ = calc_effective_non_dimensional_shear_stress.(
        area,
        width,
        discharge,
        param.manning_n,
        param.specific_gravity,
        param.g,
        mean_diameter,
        spec_diameter
    )
    
    return τₑᵢ
end

function calc_effective_non_dimensional_shear_stress(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    mean_diameter =
        average_neighbors_target_hour(
            ParticleSize.get_average_simulated_particle_size_dist(
                df,
                sediment_size,
                target_hour
            )
        ) ./ 1000

    τₑᵢ = calc_effective_non_dimensional_shear_stress.(
        area,
        width,
        discharge,
        param.manning_n,
        param.specific_gravity,
        param.g,
        mean_diameter,
        mean_diameter
    )
    
    return τₑᵢ
end

"""
特定年の有効無次元掃流力の平均値を求める。
"""
function calc_effective_non_dimensional_shear_stress_yearly_mean(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year::Int,
    diameter_m::AbstractFloat
    )

    Statistics.mean(
        i -> calc_effective_non_dimensional_shear_stress(
            df,
            sediment_size,
            param,
            i,
            diameter_m
        ),
        range(
            start=each_year_timing.dict[year][1],
            stop=each_year_timing.dict[year][2]
        )
    )

end

"""
複数年の有効無次元掃流力の年平均値を求める。
"""
function calc_effective_non_dimensional_shear_stress_yearly_mean(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,
    diameter_m::AbstractFloat
    )

    Statistics.mean(
        year -> calc_effective_non_dimensional_shear_stress_yearly_mean(
            df,
            sediment_size,
            param,
            each_year_timing,
            year,
            diameter_m
        ),
        range(
            start=year_first,
            stop=year_last
        )
    )

end

"""
平均粒径に対応する複数年の年平均の有効無次元掃流力を計算する
"""
function calc_effective_non_dimensional_shear_stress_yearly_mean(
    df::DataFrames.AbstractDataFrame,
    sediment_size::DataFrames.AbstractDataFrame,
    param::Param,
    start_year::Int,
    last_year::Int,
    each_year_timing::Each_year_timing
)


    Statistics.mean(
        i -> calc_effective_non_dimensional_shear_stress(
            df,
            sediment_size,
            param,
            i
        ),
        range(
            start=each_year_timing.dict[start_year][1],
            stop=each_year_timing.dict[last_year][2]
        )
    )

end

# 限界無次元掃流力

function calc_critical_non_dimensional_shear_stress(
    diameter_m::T,
    specific_gravity::T,
    gravity_accel::T
    ) where {T<:AbstractFloat}


    u_cm = calc_critical_friction_velocity(diameter_m)

    τ_cm = calc_non_dimensional_shear_stress(
        u_cm,
        specific_gravity,
        gravity_accel,
        diameter_m
    )

    return τ_cm

end

function calc_critical_non_dimensional_shear_stress(
    spec_diameter_m::T,
    mean_diameter_m::T,
    specific_gravity::T,
    gravity_accel::T
    ) where {T<:AbstractFloat}

    τ_cm = calc_critical_non_dimensional_shear_stress(
        mean_diameter_m,
        specific_gravity,
        gravity_accel
    )
    
    τ_ci = if spec_diameter_m / mean_diameter_m >= 0.4
        
        τ_cm * (
            log10(19) /
                log10(19 * spec_diameter_m / mean_diameter_m)
        )

    else
        
        0.85 *τ_cm * (mean_diameter_m / spec_diameter_m)

    end

    return τ_ci

end

function calc_critical_non_dimensional_shear_stress(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    spec_diameter_m::AbstractFloat,
    param::Param,
    target_hour::Int,
    )

    mean_diameter_m =
        average_neighbors_target_hour(
            ParticleSize.get_average_simulated_particle_size_dist(
                df,
                sediment_size,
                target_hour
            )
        ) ./ 1000

    τ_ci = calc_critical_non_dimensional_shear_stress.(
        spec_diameter_m,
        mean_diameter_m,
        params.specific_gravity,
        params.g
    )

    return τ_ci

end

function calc_critical_non_dimensional_shear_stress(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    mean_diameter_m =
        average_neighbors_target_hour(
            ParticleSize.get_average_simulated_particle_size_dist(
                df,
                sediment_size,
                target_hour
            )
        ) ./ 1000

    τ_cm = calc_critical_non_dimensional_shear_stress.(
        mean_diameter_m,
        params.specific_gravity,
        params.g
    )

    return τ_cm

end

"""
特定年の限界無次元掃流力の平均値を求める。
"""
function calc_critical_non_dimensional_shear_stress_yearly_mean(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year::Int,
    diameter_m::AbstractFloat
    )

    τ_c = calc_critical_non_dimensional_shear_stress(
        df,
        sediment_size,
        diameter_m,
        param,
        each_year_timing.dict[year][1]
    )

    for target_hour in (each_year_timing.dict[year][1]+1):each_year_timing.dict[year][2]

        τ_c .= τ_c .+ calc_critical_non_dimensional_shear_stress(
            df,
            sediment_size,
            diameter_m,
            param,
            target_hour
        )

    end

    τ_c .= τ_c ./ (each_year_timing.dict[year][2] - each_year_timing.dict[year][1] + 1)

    return τ_c
end

"""
複数年の限界無次元掃流力の年平均値を求める。
"""
function calc_critical_non_dimensional_shear_stress_yearly_mean(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,    
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,    
    diameter_m::AbstractFloat
    )

    τ_c = calc_critical_non_dimensional_shear_stress_yearly_mean(
        df,
        sediment_size,
        param,
        each_year_timing,
        year_first,
        diameter_m
    )

    
    for year in (year_first + 1):year_last

        τ_c .= τ_c .+ calc_critical_non_dimensional_shear_stress_yearly_mean(
            df,
            sediment_size,
            param,
            each_year_timing,
            year,
            diameter_m
        )

    end

    τ_c .= τ_c ./ (year_last - year_first + 1)

    return τ_c
end

"""
複数年の無次元掃流力と限界無次元掃流力の平均値の比率を求める。
"""
function calc_ratio_critical_standard_non_dimensional_shear_stress_yearly_mean(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,    
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int,    
    diameter_m::AbstractFloat
    )


    τ_c = calc_critical_non_dimensional_shear_stress_yearly_mean(
        df,
        sediment_size,    
        param,
        each_year_timing,
        year_first,
        year_last,    
        diameter_m
    )

    τₛ = calc_non_dimensional_shear_stress_yearly_mean(
        df,
        param,
        each_year_timing,
        year_first,
        year_last,    
        diameter_m
    )

    return τ_c ./ τₛ
    
end
