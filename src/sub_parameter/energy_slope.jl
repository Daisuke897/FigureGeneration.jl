function calc_energy_slope(
    area::T,
    width::T,
    discharge::T,
    manning_n::T
    ) where {T<:AbstractFloat}

    h_d = calc_hydraulic_depth(area, width)

    i_e = (manning_n * discharge / (h_d ^ (2/3)) / area) ^2

    return i_e
end

function calc_energy_slope(
    df::DataFrames.DataFrame,
    param::Param,
    target_hour::Int
    )

    area      = average_neighbors_target_hour(df, :Aw, target_hour)
    width     = average_neighbors_target_hour(df, :Bw, target_hour)

    discharge = average_neighbors_target_hour(df, :Qw, target_hour)

    i_e = calc_energy_slope.(area, width, discharge, param.manning_n)

    return i_e
end

"""
特定年のエネルギー勾配の平均値を求める。
"""
function calc_energy_slope_yearly_mean(
    df::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year::Int
    )

    i_e = Statistics.mean(
        target_hour -> calc_energy_slope(
            df,
            param,
            target_hour
        ),
        range(start = each_year_timing.dict[year][1],
              stop = each_year_timing.dict[year][2])
    )
    
    return i_e
    
end

"""
複数年のエネルギー勾配の平均値を求める。
"""
function calc_energy_slope_yearly_mean(
    df::DataFrames.DataFrame,
    param::Param,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int
    )

    i_e = Statistics.mean(
        target_year -> calc_energy_slope_yearly_mean(
            df,
            param,
            each_year_timing,
            target_year
        ),
        range(start = year_first,
              stop = year_last)
    )
    
    return i_e
    
end
