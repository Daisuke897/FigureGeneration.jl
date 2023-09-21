# 流速について

function calc_water_velocity(
    df::DataFrames.DataFrame,
    target_hour::Int
    )

    i_first, i_last =
        GeneralGraphModule.decide_index_number(target_hour)

    return df[i_first:i_last, :Ux]

end

"""
特定年の流速の平均値を求める。
"""
function calc_water_velocity_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year::Int
    )

    water_velocity = calc_water_velocity(
        df,
        each_year_timing.dict[year][1]
    )

    for target_hour in (each_year_timing.dict[year][1]+1):each_year_timing.dict[year][2]

        water_velocity .= water_velocity .+ calc_water_velocity(
            df,
            target_hour
        )

    end

    water_velocity .=
        water_velocity ./ (each_year_timing.dict[year][2] - each_year_timing.dict[year][1] + 1)

    return water_velocity

end

"""
複数年の流速の平均値を求める。
"""
function calc_water_velocity_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int    
    )

    water_velocity = calc_water_velocity_yearly_mean(
        df,
        each_year_timing,
        year_first
    )

    for year in (year_first + 1):year_last

        water_velocity .= water_velocity .+ calc_water_velocity_yearly_mean(
            df,
            each_year_timing,
            year
        )

    end

    water_velocity .= water_velocity ./ (year_last - year_first + 1)

    return water_velocity

end
