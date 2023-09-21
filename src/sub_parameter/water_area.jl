# 面積について

"""
特定時期の水の面積を求める。
"""
function calc_water_area(
    df::DataFrames.DataFrame,
    target_hour::Int
    )

    i_first, i_last =
        GeneralGraphModule.decide_index_number(target_hour)

    return df[i_first:i_last, :Aw]

end

"""
特定年の水の面積の平均値を求める。
"""
function calc_water_area_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year::Int
    )

    water_area = calc_water_area(
        df,
        each_year_timing.dict[year][1]
    )

    for target_hour in (each_year_timing.dict[year][1]+1):each_year_timing.dict[year][2]

        water_area .= water_area .+ calc_water_area(
            df,
            target_hour
        )

    end

    water_area .=
        water_area ./ (each_year_timing.dict[year][2] - each_year_timing.dict[year][1] + 1)

    return water_area

end

"""
複数年の水の面積の平均値を求める。
"""
function calc_water_area_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int    
    )

    water_area = calc_water_area_yearly_mean(
        df,
        each_year_timing,
        year_first
    )

    for year in (year_first + 1):year_last

        water_area .= water_area .+ calc_water_area_yearly_mean(
            df,
            each_year_timing,
            year
        )

    end

    water_area .= water_area ./ (year_last - year_first + 1)

    return water_area
    
end
