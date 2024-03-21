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
    df::DataFrames.AbstractDataFrame,
    each_year_timing::Each_year_timing,
    year::Int
    )

    Statistics.mean(
        i -> calc_water_hydraulic_depth(
            df,
            i
        ),
        range(
            start=each_year_timing.dict[year][1],
            stop=each_year_timing.dict[year][2]
        )
    )

end

"""
複数年の径深の平均値を求める。
"""
function calc_water_hydraulic_depth_yearly_mean(
    df::DataFrames.AbstractDataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int
    )

    Statistics.mean(
        year -> calc_water_hydraulic_depth_yearly_mean(
            df,
            each_year_timing,
            year
        ),
        range(
            start=year_first,
            stop=year_last
        )
    )

end
