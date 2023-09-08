function calc_friction_velocity(
    area::T,
    width::T,
    discharge::T,
    manning_n::T,
    gravity_accel::T
    ) where {T<:AbstractFloat}

    hydraulic_depth = calc_hydraulic_depth(
        area,
        width
    )
    
    energy_slope = calc_energy_slope(
        area, width, discharge, manning_n
    )
    
    uₛ = sqrt(gravity_accel * hydraulic_depth * energy_slope)

    return uₛ
end

function calc_friction_velocity(
    df::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    uₛ    = calc_friction_velocity.(
        area,
        width,
        discharge,
        param.manning_n,
        param.g
    )
    
    return uₛ
end

"""
特定年の（通常）摩擦速度の平均値を求める。
"""
function calc_friction_velocity_yearly_mean(
    df::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year::Int
    )

    uₛ = calc_friction_velocity(
        df,
        param,
        each_year_timing.dict[year][1]
    )

    for target_hour in (each_year_timing.dict[year][1]+1):each_year_timing.dict[year][2]

        uₛ .= uₛ .+ calc_friction_velocity(
            df,
            param,
            each_year_timing.dict[year][1]
        )

    end

    uₛ .= uₛ ./ (each_year_timing.dict[year][2] - each_year_timing.dict[year][1] + 1)

    return uₛ

end

"""
複数年の（通常）摩擦速度の平均値を求める。
"""
function calc_friction_velocity_yearly_mean(
    df::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int    
    )

    uₛ = calc_friction_velocity(
        df,
        param,
        year_first
    )

    for year in (year_first + 1):year_last

        uₛ .= uₛ .+ calc_friction_velocity(
            df,
            param,
            year
        )

    end

    uₛ .= uₛ ./ (year_last - year_first + 1)

    return uₛ

end

function calc_effective_friction_velocity(
    discharge::T,
    area::T,
    depth::T,
    mean_diameter::T,
    τₘ::T
    ) where {T<:AbstractFloat}

    uₑₘ = discharge / (
        area * (
            6 + 2.5 * log(
                depth / (
                    mean_diameter * (1 + 2 * τₘ)
                )
            )
        )
    )

    return uₑₘ

end

function calc_effective_friction_velocity(
    discharge::T,
    area::T,
    depth::T,
    mean_diameter::T,
    width::T,
    manning_n::T,
    specific_gravity::T,
    gravity_accel::T
    ) where {T<:AbstractFloat}

    τₘ = calc_non_dimensional_shear_stress(
        area,
        width,
        discharge,
        manning_n,
        specific_gravity,
        gravity_accel,
        mean_diameter
    )

    uₑₘ = calc_effective_friction_velocity(
        discharge,
        area,
        depth,
        mean_diameter,
        τₘ
    )

    return uₑₘ

end

function calc_effective_friction_velocity(
    df::DataFrames.DataFrame,
    sediment_size::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    depth     = area ./ width

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    mean_diameter =
        average_neighbors_target_hour(
            ParticleSize.get_average_simulated_particle_size_dist(
                df,
                sediment_size,
                target_hour
            )
        ) ./ 1000

    uₑₘ = calc_effective_friction_velocity.(
        discharge,
        area,
        depth,
        mean_diameter,
        width,
        param.manning_n,
        param.specific_gravity,
        param.g,
    )
    
    return uₑₘ
end

function calc_critical_friction_velocity_square(
    diameter_m::T
    ) where {T<:AbstractFloat}

    diameter_cm = diameter_m * 100

    if diameter_cm >= 0.303 
        u_cm_2=80.9*diameter_cm
    elseif diameter_cm >= 0.118 
        u_cm_2=134.6*diameter_cm^(31/22)
    elseif diameter_cm >= 0.0565
        u_cm_2=55.0*diameter_cm
    elseif diameter_cm >= 0.0065
        u_cm_2=8.41*diameter_cm^(11/32)
    else
        u_cm_2=2226.0*diameter_cm
    end

    u_cm_2 = u_cm_2 / 100^2

    return u_cm_2    

end


function calc_critical_friction_velocity(
    diameter_m::T
    ) where {T<:AbstractFloat}

    u_cm = sqrt(
        calc_critical_friction_velocity_square(
            diameter_m
        )
    )

    return u_cm    

end
