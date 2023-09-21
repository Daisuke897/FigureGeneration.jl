# 水位について

"""
特定時期の水位を求める。
"""
function calc_water_level(
    df::DataFrames.DataFrame,
    target_hour::Int
    )

    i_first, i_last =
        GeneralGraphModule.decide_index_number(target_hour)

    return df[i_first:i_last, :Z]

end

"""
特定年の水位の平均値を求める。
"""
function calc_water_level_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year::Int
    )

    water_level = calc_water_level(
        df,
        each_year_timing.dict[year][1]
    )

    for target_hour in (each_year_timing.dict[year][1]+1):each_year_timing.dict[year][2]

        water_level .= water_level .+ calc_water_level(
            df,
            target_hour
        )

    end

    water_level .=
        water_level ./ (each_year_timing.dict[year][2] - each_year_timing.dict[year][1] + 1)

    return water_level

end

"""
複数年の水位の平均値を求める。
"""
function calc_water_level_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int    
    )

    water_level = calc_water_level_yearly_mean(
        df,
        each_year_timing,
        year_first
    )

    for year in (year_first + 1):year_last

        water_level .= water_level .+ calc_water_level_yearly_mean(
            df,
            each_year_timing,
            year
        )

    end

    water_level .= water_level ./ (year_last - year_first + 1)

    return water_level

end
