# diameter unit: m (not mm)

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

function calc_non_dimensional_shear_stress(
    df::DataFrames.DataFrame,
    param::Param,
    target_hour::Int,
    diameter::AbstractFloat
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
        diameter    
    )
    
    return τₛ
end

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

    τ_ci = calc_critical_non_dimensional_shear_stress.(
        spec_diameter_m,
        mean_diameter_m,
        params.specific_gravity,
        params.g
    )

    return τ_ci

end
