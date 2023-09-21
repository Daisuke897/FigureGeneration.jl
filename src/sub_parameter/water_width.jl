# 水路幅について

"""
特定時期の水路幅を求める。
"""
function calc_water_width(
    df::DataFrames.DataFrame,
    target_hour::Int
    )
    
    i_first, i_last =
        GeneralGraphModule.decide_index_number(target_hour)

    return df[i_first:i_last, :Bw]

end

"""
特定年の水路幅の平均値を求める。
"""
function calc_water_width_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year::Int
    )

    water_width = calc_water_width(
        df,
        each_year_timing.dict[year][1]
    )

    for target_hour in (each_year_timing.dict[year][1]+1):each_year_timing.dict[year][2]

        water_width .= water_width .+ calc_water_width(
            df,
            target_hour
        )

    end

    water_width .=
        water_width ./ (each_year_timing.dict[year][2] - each_year_timing.dict[year][1] + 1)

    return water_width

end

"""
複数年の水路幅の平均値を求める。
"""
function calc_water_width_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int    
    )

    water_width = calc_water_width_yearly_mean(
        df,
        each_year_timing,
        year_first
    )

    for year in (year_first + 1):year_last

        water_width .= water_width .+ calc_water_width_yearly_mean(
            df,
            each_year_timing,
            year
        )

    end

    water_width .= water_width ./ (year_last - year_first + 1)

    return water_width
    
end
