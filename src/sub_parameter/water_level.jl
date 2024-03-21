# 水位について

"""
特定時期の水位を求める。
"""
function calc_water_level(
    df::DataFrames.AbstractDataFrame,
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
    df::DataFrames.AbstractDataFrame,
    each_year_timing::Each_year_timing,
    year::Int
    )

    Statistics.mean(
        i -> calc_water_level(
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
複数年の水位の平均値を求める。
"""
function calc_water_level_yearly_mean(
    df::DataFrames.AbstractDataFrame,
    each_year_timing::Each_year_timing,
    year_first::Int,
    year_last::Int
    )

    Statistics.mean(
        year -> calc_water_level_yearly_mean(
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
