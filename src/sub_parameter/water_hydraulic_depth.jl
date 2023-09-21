# 径深について

"""
特定時期の径深を求める。
"""
function calc_water_hydraulic_depth(
    df::DataFrames.DataFrame,
    target_hour::Int
    )

    hydraulic_depth =
        calc_water_area(df, target_hour) ./
        calc_water_width(df, target_hour)

    return hydraulic_depth

end

"""
特定年の径深の平均値を求める。
"""
function calc_water_hydraulic_depth_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year::Int
    )

    hydraulic_depth = calc_water_hydraulic_depth(
        df,
        each_year_timing.dict[year][1]
    )

    for target_hour in (each_year_timing.dict[year][1]+1):each_year_timing.dict[year][2]

        hydraulic_depth .= hydraulic_depth .+ calc_water_hydraulic_depth(
            df,
            target_hour
        )

    end

    hydraulic_depth .=
        hydraulic_depth ./ (each_year_timing.dict[year][2] - each_year_timing.dict[year][1] + 1)

    return hydraulic_depth

end

"""
複数年の径深の平均値を求める。
"""
function calc_water_hydraulic_depth_yearly_mean(
    df::DataFrames.DataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int    
    )

    hydraulic_depth = calc_water_hydraulic_depth_yearly_mean(
        df,
        each_year_timing,
        year_first
    )

    for year in (year_first + 1):year_last

        hydraulic_depth .= hydraulic_depth .+ calc_water_hydraulic_depth_yearly_mean(
            df,
            each_year_timing,
            year
        )

    end

    hydraulic_depth .= hydraulic_depth ./ (year_last - year_first + 1)

    return hydraulic_depth
    
end
