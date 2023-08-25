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
        )

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
