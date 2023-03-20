#    Copyright (C) 2022  Daisuke Nakahara

#    This file is part of FigureGeneration

#    FigureGeneration is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    FigureGeneration is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

module SedimentLoad

using Printf,
      Plots,
      Statistics,
      DataFrames,
      StatsPlots,
      CSV,
      ..GeneralGraphModule

export
    make_graph_sediment_load_each_year_diff_scale_ja,
    make_graph_sediment_load_each_year_diff_scale_en,
    make_graph_sediment_load_each_year_same_scale_ja,
    make_graph_sediment_load_each_year_same_scale_en,
    make_graph_suspended_volume_flow_dist,
    make_graph_bedload_volume_flow_dist,
    make_graph_sediment_volume_flow_dist,
    make_graph_suspended_load_target_hour_ja,
    make_graph_bedload_target_hour_ja,
    make_graph_suspended_bedload_target_hour_ja,
    make_graph_yearly_mean_suspended_load,
    make_graph_yearly_mean_bedload,
    make_graph_particle_yearly_mean_suspended,
    make_graph_particle_yearly_mean_bedload,
    make_graph_condition_change_yearly_mean_suspended_load,    
    make_graph_condition_change_yearly_mean_bedload,
    make_graph_particle_suspended_volume_each_year_ja,
    make_graph_particle_bedload_volume_each_year_ja,
    make_graph_particle_sediment_volume_each_year_ja,
    make_suspended_sediment_per_year_csv,
    make_bedload_sediment_per_year_csv,
    make_suspended_sediment_mean_year_csv,
    make_bedload_sediment_mean_year_csv
    
#特定位置の各年の年間掃流砂量の配列を出力する関数
function bedload_sediment_volume_each_year!(
    bedload_sediment, area_index::Int, data_file::DataFrame, each_year_timing
    )

    area_meter = 200 * (area_index - 1)

    for i in 1:(1999-1965+1)
        target_year=1965+i-1
        bedload_sediment[i]=sum(
	    data_file[data_file.I .== area_meter, :Qball][each_year_timing[target_year][1]+1:each_year_timing[target_year][2]+1]
	    )
    end
    
    return bedload_sediment
    
end


function bedload_sediment_volume_each_year(
    area_index::Int, data_file::DataFrame, each_year_timing
    )

    bedload_sediment = zeros(Float64,1999-1965+1)
    
    bedload_sediment_volume_each_year!(
        bedload_sediment, area_index, data_file, each_year_timing
	)

    return bedload_sediment

end


#特定位置の各年の年間浮遊砂量の配列を出力する関数
function suspended_sediment_volume_each_year!(
    suspended_sediment, area_index::Int, data_file::DataFrame, each_year_timing
    )

    area_meter = 200 * (area_index - 1)

    for i in 1:(1999-1965+1)
        target_year=1965+i-1
        suspended_sediment[i]=sum(
	    data_file[data_file.I .== area_meter, :Qsall][each_year_timing[target_year][1]+1:each_year_timing[target_year][2]+1]
	    )
    end
    
    return suspended_sediment
    
end


function suspended_sediment_volume_each_year(
    area_index::Int, data_file::DataFrame, each_year_timing
    )

    suspended_sediment = zeros(Float64,1999-1965+1)
    
    suspended_sediment_volume_each_year!(
        suspended_sediment, area_index, data_file, each_year_timing
	)

    return suspended_sediment

end

#特定位置の各年の年間の任意粒径階の流砂量の配列を出力する関数

function sediment_volume_each_year!(
    sediment, area_index::Int,
    data_file::DataFrame, each_year_timing,
    target_symbol::Symbol
    )

    area_meter = 200 * (area_index - 1)

    for i in 1:(1999-1965+1)
        target_year=1965+i-1
        sediment[i]=sum(
	    data_file[data_file.I .== area_meter, target_symbol][
                each_year_timing[target_year][1]+1:each_year_timing[target_year][2]+1
                ]
	    )
    end
    
end

function sediment_volume_each_year(
    area_index::Int, data_file::DataFrame,
    each_year_timing, target_symbol::Symbol
    )

    sediment = zeros(Float64,1999-1965+1)
    
    sediment_volume_each_year!(
        sediment, area_index, data_file,
        each_year_timing, target_symbol
	)

    return sediment
    
end

#全粒径階の流砂量を取り出す

function particle_suspended_volume_each_year(
    area_index::Int, data_file::DataFrame,
    each_year_timing, sediment_size
    )

    sediment_size_num = size(sediment_size)[1]

    sediment = zeros(Float64, 1999-1965+1, sediment_size_num)

    @views for particle_class_num in 1:sediment_size_num
        sediment_sub = sediment[:, particle_class_num]
        sediment_volume_each_year!(
            sediment_sub,
            area_index, data_file,
            each_year_timing,
            Symbol(string("Qsall", Printf.@sprintf("%02i", particle_class_num)))
            )
    end

    return sediment
    
end

function particle_bedload_volume_each_year(
    area_index::Int, data_file::DataFrame,
    each_year_timing, sediment_size
    )

    sediment_size_num = size(sediment_size)[1]

    sediment = zeros(Float64, 1999-1965+1, sediment_size_num)

    @views for particle_class_num in 1:sediment_size_num
        sediment_sub = sediment[:, particle_class_num]
        sediment_volume_each_year!(
            sediment_sub,
            area_index, data_file,
            each_year_timing,
            Symbol(string("Qball", Printf.@sprintf("%02i", particle_class_num)))
            )
    end

    return sediment
    
end

#積み上げの図をつくる
function make_graph_particle_suspended_volume_each_year_ja(
    area_index::Int, data_file::DataFrame,
    each_year_timing, sediment_size, river_length_km
    )

    suspended_sediment = particle_suspended_volume_each_year(
        area_index, data_file,
        each_year_timing, sediment_size
        )

    strings_sediment_size =
        string.(round.(sediment_size[:,:diameter_mm], digits=3))

    area_km = abs(river_length_km - 0.2 * (area_index - 1))
    
    title_graph = string(
        "河口から ", round(area_km, digits=2), " km"
    )
    
    hline([-10], line=:black, label="", linestyle=:dot, linewidth=1)
    
    StatsPlots.groupedbar!(
        collect(1965:1999), suspended_sediment,
        bar_position = :stack,
        legend = :outerright,
        ylims=(0, 2e7),
        xlims=(1964, 2000),
        ylabel="浮遊砂量 (m³/年)",
        xlabel="年",
	xticks=[1965, 1975, 1985, 1995],
        label=permutedims(strings_sediment_size),
        label_title="粒径 (mm)",
        legend_font_pointsize=10,
        title = title_graph,
        palette=:tab20
    )

end    

function make_graph_particle_bedload_volume_each_year_ja(
    area_index::Int, data_file::DataFrame,
    each_year_timing, sediment_size, river_length_km
    )

    bedload_sediment = particle_bedload_volume_each_year(
        area_index, data_file,
        each_year_timing, sediment_size
        )

    strings_sediment_size =
        string.(round.(sediment_size[:,:diameter_mm], digits=3))

    area_km = abs(river_length_km - 0.2 * (area_index - 1))
    
    title_graph = string(
        "河口から ", round(area_km, digits=2), " km"
        ) 

    hline([-10], line=:black, label="", linestyle=:dot, linewidth=1)
   
    StatsPlots.groupedbar!(
        collect(1965:1999), bedload_sediment,
        bar_position = :stack,
        legend = :outerright,
        ylims=(0, 1.5e5),
        xlims=(1964, 2000),
        ylabel="掃流砂量 (m³/年)",
        xlabel="年",
	xticks=[1965, 1975, 1985, 1995],
        label=permutedims(strings_sediment_size),
        label_title="粒径 (mm)",
        legend_font_pointsize=10,
        title = title_graph,
        palette=:tab20
    )

end

function make_graph_particle_sediment_volume_each_year_ja(
    area_index::Int, data_file::DataFrame,
    each_year_timing, sediment_size, river_length_km
    )

    p1 = make_graph_particle_suspended_volume_each_year_ja(
        area_index, data_file,
        each_year_timing, sediment_size, river_length_km
    )

    plot!(p1, xlabel="", legend=:none, ylabel="浮遊 (m³/年)")

    p2 = make_graph_particle_bedload_volume_each_year_ja(
        area_index, data_file,
        each_year_timing, sediment_size, river_length_km
    )

    plot!(p2, title="", bottom_margin=30Plots.mm, ylabel="掃流 (m³/年)")

    plot(p1, p2, layout=Plots.@layout[a; b])

end


#各年の年間流砂量のグラフを出力する関数 日本語バージョン（縦軸のスケールは異なる）
function make_graph_sediment_load_each_year_diff_scale_ja(
    data_file::DataFrame, each_year_timing
    )
    
    bedload_sedi_up = zeros(Float64,1999-1965+1)
    suspended_sedi_up = zeros(Float64,1999-1965+1)
    
    bedload_sediment_volume_each_year!(bedload_sedi_up, 1, data_file, each_year_timing)
    suspended_sediment_volume_each_year!(suspended_sedi_up, 1, data_file, each_year_timing)    
    
    bedload_sedi_down = zeros(Float64,1999-1965+1)
    suspended_sedi_down = zeros(Float64,1999-1965+1)
        
    bedload_sediment_volume_each_year!(bedload_sedi_down, 390, data_file, each_year_timing)
    suspended_sediment_volume_each_year!(suspended_sedi_down, 390, data_file, each_year_timing)
    
    year_list=[i for i in 1965:1999]
    
    l = @layout[a b;c d]
    
    p1 = plot(year_list, suspended_sedi_up,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        bar_position=:stack, guidefontsize=18,
        titlefontsize=15, ylabel="年間浮遊砂量 (m³/year)",
        tickfontsize=18, label="上流端 浮遊砂", seriestype=:bar,
        color=:firebrick, legend_font_pointsize=13)
    
    p2 = plot(year_list, bedload_sedi_up,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e5),
        titlelocation=:left,titlefontsize=15, ylabel="年間掃流砂量 (m³/year)",
        bar_position=:stack, xlabel="年", guidefontsize=18,
        tickfontsize=18, label="上流端 掃流砂", seriestype=:bar,
        color=:royalblue, legend_font_pointsize=13)   
    
    p3 = plot(year_list, suspended_sedi_down,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        guidefontsize=18, seriestype=:bar, legend_font_pointsize=13,
        titlefontsize=15, ylabel="年間浮遊砂量 (m³/year)",
        tickfontsize=18, label="河口 浮遊砂", color=:darkorange)
    
    p4 = plot(year_list, bedload_sedi_down,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e5),
        titlelocation=:left,titlefontsize=15, ylabel="年間掃流砂量 (m³/year)",
        xlabel="年", guidefontsize=18, seriestype=:bar,
        legend_font_pointsize=13,
        tickfontsize=18, label="河口 掃流砂", color=:midnightblue)
        
    plot!(p1, p3, p2, p4, layout=l, legend=:best, dpi=300, size=(1200,600),
        topmargin=10Plots.mm, rightmargin=30Plots.mm)
    
end

#各年の年間流砂量のグラフを出力する関数 英語バージョン（縦軸のスケールは異なる）
function make_graph_sediment_load_each_year_diff_scale_en(
    data_file::DataFrame, each_year_timing
    )
    
    bedload_sedi_up = zeros(Float64,1999-1965+1)
    suspended_sedi_up = zeros(Float64,1999-1965+1)
    
    bedload_sediment_volume_each_year!(bedload_sedi_up, 1, data_file, each_year_timing)
    suspended_sediment_volume_each_year!(suspended_sedi_up, 1, data_file, each_year_timing)    
    
    bedload_sedi_down = zeros(Float64,1999-1965+1)
    suspended_sedi_down = zeros(Float64,1999-1965+1)
        
    bedload_sediment_volume_each_year!(bedload_sedi_down, 390, data_file, each_year_timing)
    suspended_sediment_volume_each_year!(suspended_sedi_down, 390, data_file, each_year_timing)
    
    year_list=[i for i in 1965:1999]
    
    l = @layout[a b;c d]
    
    p1 = plot(year_list, suspended_sedi_up,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        bar_position=:stack, guidefontsize=18,
        titlefontsize=15, ylabel="Yearly suspended load (m³/year)",
        tickfontsize=18, label="Upstream end", seriestype=:bar,
        color=:firebrick, legend_font_pointsize=13)
    
    p2 = plot(year_list, bedload_sedi_up,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e5),
        titlelocation=:left,titlefontsize=15, ylabel="Yearly bedload (m³/year)",
        bar_position=:stack, xlabel="年", guidefontsize=18,
        tickfontsize=18, label="Upstream end", seriestype=:bar,
        color=:royalblue, legend_font_pointsize=13)   
    
    p3 = plot(year_list, suspended_sedi_down,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        guidefontsize=18, seriestype=:bar, legend_font_pointsize=13,
        titlefontsize=15, ylabel="Yearly suspended load (m³/year)",
        tickfontsize=18, label="Estuary", color=:darkorange)
    
    p4 = plot(year_list, bedload_sedi_down,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e5),
        titlelocation=:left,titlefontsize=15, ylabel="Yearly bedload (m³/year)",
        xlabel="年", guidefontsize=18, seriestype=:bar,
        legend_font_pointsize=13,
        tickfontsize=18, label="Estuary", color=:midnightblue)
    
    plot!(p1, p3, p2, p4, layout=l, legend=:best, dpi=300, size=(1200,600),
        topmargin=10Plots.mm, rightmargin=30Plots.mm)
    
end

#各年の年間流砂量のグラフを出力する関数 日本語バージョン（縦軸のスケールは同じ）
function make_graph_sediment_load_each_year_same_scale_ja(
    data_file::DataFrame, each_year_timing
    )
    
    bedload_sedi_up = zeros(Float64,1999-1965+1)
    suspended_sedi_up = zeros(Float64,1999-1965+1)
    
    bedload_sediment_volume_each_year!(bedload_sedi_up, 1, data_file, each_year_timing)
    suspended_sediment_volume_each_year!(suspended_sedi_up, 1, data_file, each_year_timing)    
    
    bedload_sedi_down = zeros(Float64,1999-1965+1)
    suspended_sedi_down = zeros(Float64,1999-1965+1)
        
    bedload_sediment_volume_each_year!(bedload_sedi_down, 390, data_file, each_year_timing)
    suspended_sediment_volume_each_year!(suspended_sedi_down, 390, data_file, each_year_timing)
    
    year_list=[i for i in 1965:1999]
    
    l = @layout[a b;c d]
    
    p1 = plot(year_list, suspended_sedi_up,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        bar_position=:stack, guidefontsize=18,
        titlefontsize=15, ylabel="年間浮遊砂量 (m³/year)",
        tickfontsize=18, label="上流端 浮遊砂", seriestype=:bar,
        color=:firebrick, legend_font_pointsize=13)
    
    p2 = plot(year_list, bedload_sedi_up,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        titlelocation=:left,titlefontsize=15, ylabel="年間掃流砂量 (m³/year)",
        bar_position=:stack, xlabel="年", guidefontsize=18,
        tickfontsize=18, label="上流端 掃流砂", seriestype=:bar,
        color=:royalblue, legend_font_pointsize=13)   
    
    p3 = plot(year_list, suspended_sedi_down,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        guidefontsize=18, seriestype=:bar, legend_font_pointsize=13,
        titlefontsize=15, ylabel="年間浮遊砂量 (m³/year)",
        tickfontsize=18, label="河口 浮遊砂", color=:darkorange)
    
    p4 = plot(year_list, bedload_sedi_down,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        titlelocation=:left,titlefontsize=15, ylabel="年間掃流砂量 (m³/year)",
        xlabel="年", guidefontsize=18, seriestype=:bar,
        legend_font_pointsize=13,
        tickfontsize=18, label="河口 掃流砂", color=:midnightblue)
    
    
    plot!(p1, p3, p2, p4, layout=l, legend=:best, dpi=300, size=(1200,600),
        topmargin=10Plots.mm, rightmargin=30Plots.mm)
    
end

#各年の年間流砂量のグラフを出力する関数 英語バージョン（縦軸のスケールは同じ）
function make_graph_sediment_load_each_year_same_scale_en(
    data_file::DataFrame, each_year_timing
    )
    
    bedload_sedi_up = zeros(Float64,1999-1965+1)
    suspended_sedi_up = zeros(Float64,1999-1965+1)
    
    bedload_sediment_volume_each_year!(bedload_sedi_up, 1, data_file, each_year_timing)
    suspended_sediment_volume_each_year!(suspended_sedi_up, 1, data_file, each_year_timing)    
    
    bedload_sedi_down = zeros(Float64,1999-1965+1)
    suspended_sedi_down = zeros(Float64,1999-1965+1)
        
    bedload_sediment_volume_each_year!(bedload_sedi_down, 390, data_file, each_year_timing)
    suspended_sediment_volume_each_year!(suspended_sedi_down, 390, data_file, each_year_timing)
    
    year_list=[i for i in 1965:1999]
    
    l = @layout[a b;c d]
    
    p1 = plot(year_list, suspended_sedi_up,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        bar_position=:stack, guidefontsize=18,
        titlefontsize=15, ylabel="Yearly suspended load (m³/year)",
        tickfontsize=18, label="Upstream end", seriestype=:bar,
        color=:firebrick, legend_font_pointsize=13)
    
    p2 = plot(year_list, bedload_sedi_up,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        titlelocation=:left,titlefontsize=15, ylabel="Yearly bedload (m³/year)",
        bar_position=:stack, xlabel="年", guidefontsize=18,
        tickfontsize=18, label="Upstream end", seriestype=:bar,
        color=:royalblue, legend_font_pointsize=13)   
    
    p3 = plot(year_list, suspended_sedi_down,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        guidefontsize=18, seriestype=:bar, legend_font_pointsize=13,
        titlefontsize=15, ylabel="Yearly suspended load (m³/year)",
        tickfontsize=18, label="Estuary", color=:darkorange)
    
    p4 = plot(year_list, bedload_sedi_down,
        framestyle=:box, grid=false, xlims=(1964,2001), ylims=(0,2e7),
        titlelocation=:left,titlefontsize=15, ylabel="Yearly bedload (m³/year)",
        xlabel="年", guidefontsize=18, seriestype=:bar,
        legend_font_pointsize=13,
        tickfontsize=18, label="Estuary", color=:midnightblue)
    
    
    plot!(p1, p3, p2, p4, layout=l, legend=:best, dpi=300, size=(1200,600),
        topmargin=10Plots.mm, rightmargin=30Plots.mm)
    
end

function make_graph_suspended_volume_flow_dist(
    df::DataFrame,
    target_year::Int,
    each_year_timing)

    flow_size = length(df[df.T .== 0, :I])

    sediment_load_each_year = zeros(Float64, flow_size)
    
    sediment_load_whole_area_each_year!(
        sediment_load_each_year, df, target_year,
	each_year_timing,:Qsall
	)

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(collect(0:0.2:77.8),
        reverse(sediment_load_each_year),
	title=string(target_year),
	label="",
	xlabel="Distance from the Estuary (km)",
        ylabel="Yearly Suspended\n Sediment Load (m³/year)",
	xlims=(0,77.8))
end

function make_graph_bedload_volume_flow_dist(
    df::DataFrame,
    target_year::Int,
    each_year_timing)

    flow_size = length(df[df.T .== 0, :I])
    sediment_load_each_year = zeros(Float64, flow_size)
    
    sediment_load_whole_area_each_year!(
        sediment_load_each_year, df, target_year,
	each_year_timing,:Qball
	)

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(collect(0:0.2:77.8),
        reverse(sediment_load_each_year),
	title=string(target_year),
	label="",
	xlabel="Distance from the Estuary (km)",
        ylabel="Yearly \n Bedload (m³/year)",
	xlims=(0,77.8))
end

function make_graph_sediment_volume_flow_dist(
data_file::DataFrame,
target_year::Int,
each_year_timing)

p1 = make_graph_suspended_volume_flow_dist(
data_file,target_year,each_year_timing)

plot!(p1, xlabel="", ylabel="Yearly\n Suspended\n Load\n (m³/year)",
ylims=(0, 1.4e7))

p2 = make_graph_bedload_volume_flow_dist(
data_file,target_year,each_year_timing)

plot!(p2, title="", ylabel="Yearly\n Bedload\n (m³/year)",
ylims=(0, 2.0e5))

l = @layout[a; b]

plot(p1, p2, layout=l)

end

#特定の時間の流砂量を表示できるようにする。
#浮遊砂量の図
function make_graph_suspended_load_target_hour_ja(
    target_hour,data_file,time_schedule)

    target_second = 3600 * target_hour
    
    start_index, finish_index = decide_index_number(target_hour)
    
    want_title = making_time_series_title(
                     "浮遊砂量", target_hour,
                     target_second, time_schedule
		     )

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(data_file[data_file.T .== 0, :I].*10^-3,
        reverse(data_file[start_index:finish_index,:Qs]),
        label="", fillrange=0,
        ylabel="浮遊砂量 (m³/s)", xlims=(0,77.8),ylims=(0,100),
	title=want_title, xlabel="河口からの距離 (km)",
	xticks=[0, 20, 40, 60, 77.8],
	linewidth=2, legend=:topleft,
	color=:firebrick)
end
#掃流砂量の図
function make_graph_bedload_target_hour_ja(
    target_hour,data_file,time_schedule)

    target_second = 3600 * target_hour
    
    start_index, finish_index = decide_index_number(target_hour)
    
    want_title = making_time_series_title(
                     "掃流砂量", target_hour,
                     target_second, time_schedule
		     )

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(data_file[data_file.T .== 0, :I].*10^-3,
        reverse(data_file[start_index:finish_index,:Qb]),
        label="", fillrange=0,
        ylabel="掃流砂量 (m³/s)", xlims=(0,77.8),ylims=(0,2),
	title=want_title, xlabel="河口からの距離 (km)",
	xticks=[0, 20, 40, 60, 77.8],
	linewidth=2, legend=:topleft,
	color=:royalblue)
end

#浮遊砂量と掃流砂量の2つの図
function make_graph_suspended_bedload_target_hour_ja(
    target_hour,data_file,time_schedule)

    l = @layout[a; b]

    p1 = make_graph_suspended_load_target_hour_ja(
             target_hour,data_file,time_schedule
	     )
    plot!(p1, xlabel="")

    p2 = make_graph_bedload_target_hour_ja(
             target_hour,data_file,time_schedule
	     )

    plot(p1, p2, layout=l)
end

#粒径別にも表示できるようにしたい！！
#浮遊砂の粒径別のグラフを作る！
function make_graph_suspended_load_target_hour_ja(
    target_hour,data_file,time_schedule,
    sediment_size)

    target_second = 3600 * target_hour

    start_index, finish_index = decide_index_number(target_hour)

    want_title = making_time_series_title(
                     "浮遊砂量", target_hour,
                     target_second, time_schedule
                     )

    sediment_size_num = size(sediment_size)[1]

    target_matrix = Matrix(
        data_file[start_index:finish_index,DataFrames.Between(:Qs01, Symbol(string(:Qs, Printf.@sprintf("%02i", sediment_size_num))))]
	)

    reverse!(target_matrix, dims=2)
    cumsum!(target_matrix, target_matrix, dims=2)
    reverse!(target_matrix, dims=2)
    reverse!(target_matrix, dims=1)

    strings_sediment_size =
        string.(round.(sediment_size[:,:diameter_mm], digits=3))

    p=vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(p, ylabel="浮遊砂量 (m³/s)", xlims=(0,77.8),ylims=(0,100),
        title=want_title, xlabel="河口からの距離 (km)",
        xticks=[0, 20, 40, 60, 77.8],
        linewidth=2, legend=:outerright,
	palette=:tab20,
	legend_font_pointsize=9,
        label_title="粒径(mm)",
        legend_title_font_pointsize=10)

    for i in 1:sediment_size_num
        plot!(p, data_file[data_file.T .== 0, :I].*10^-3,
	    target_matrix[:,i],
	    fillrange=0,
	    label=strings_sediment_size[i])
    end

    return p
    
end

#掃流砂のグラフ
function make_graph_bedload_target_hour_ja(
    target_hour,data_file,time_schedule,
    sediment_size)

    target_second = 3600 * target_hour

    start_index, finish_index = decide_index_number(target_hour)

    want_title = making_time_series_title(
                     "掃流砂量", target_hour,
                     target_second, time_schedule
                     )

    sediment_size_num = size(sediment_size)[1]

    target_matrix = Matrix(
        data_file[start_index:finish_index,DataFrames.Between(:Qb01, Symbol(string(:Qb, Printf.@sprintf("%02i", sediment_size_num))))]
        )

    reverse!(target_matrix, dims=2)
    cumsum!(target_matrix, target_matrix, dims=2)
    reverse!(target_matrix, dims=2)
    reverse!(target_matrix, dims=1)

    strings_sediment_size =
        string.(round.(sediment_size[:,:diameter_mm], digits=3))

    p=vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(p, ylabel="掃流砂量 (m³/s)", xlims=(0,77.8),ylims=(0,2),
        title=want_title, xlabel="河口からの距離 (km)",
        xticks=[0, 20, 40, 60, 77.8],
        linewidth=2, legend=:outerright,
        palette=:tab20,
        legend_font_pointsize=9,
        label_title="粒径(mm)",
        legend_title_font_pointsize=10)

    for i in 1:sediment_size_num
        plot!(p, data_file[data_file.T .== 0, :I].*10^-3,
            target_matrix[:,i],
            fillrange=0,
            label=strings_sediment_size[i])
    end

    return p

end

#浮遊砂量と掃流砂量の2つの図

function make_graph_suspended_bedload_target_hour_ja(
    target_hour,data_file,time_schedule,sediment_size)

    l = @layout[a; b]

    p1 = make_graph_suspended_load_target_hour_ja(
             target_hour,data_file,time_schedule,
             sediment_size)
	     
    plot!(p1, xlabel="",
          legend_font_pointsize=4)

    p2 = make_graph_bedload_target_hour_ja(
             target_hour,data_file,time_schedule,
             sediment_size)

    plot!(p2, legend_font_pointsize=4)

    plot(p1, p2, layout=l)
end

#年平均土砂量を表示できるようにプログラムを変更する。
#過去のJupyter-labのコードを参考にする。
function sediment_load_whole_area(df, target_hour::Int, tag::Symbol)

  start_index, final_index = decide_index_number(target_hour)

  return df[start_index:final_index, tag]

end

function sediment_load_whole_area_each_year!(
    sediment_load_each_year, df,
    target_year::Int, each_year_timing, tag::Symbol
    )

    for target_hour in each_year_timing[target_year][1]:each_year_timing[target_year][2]
        start_index, final_index = decide_index_number(target_hour)
        sediment_load_each_year .= sediment_load_each_year .+ df[start_index:final_index, tag]
    end

    return sediment_load_each_year
end

function sediment_load_whole_area_each_year(
    df, target_year::Int, each_year_timing, tag::Symbol
    )

    flow_size = length(df[df.T .== 0, :I])
    sediment_load_each_year = zeros(Float64, flow_size)
    sediment_load_whole_area_each_year!(
        sediment_load_each_year, df, target_year,
	each_year_timing,tag
	)

    return sediment_load_each_year
end

function yearly_mean_sediment_load_whole_area!(
    sediment_load_yearly_mean, flow_size::Int,
    df, start_year::Int, final_year::Int,
    each_year_timing, tag::Symbol)

    for target_year in start_year:final_year
        sediment_load_each_year = zeros(Float64, flow_size)
	sediment_load_whole_area_each_year!(
	    sediment_load_each_year, df, target_year,
	    each_year_timing, tag)

        sediment_load_yearly_mean .= sediment_load_yearly_mean .+ sediment_load_each_year

    end

    sediment_load_yearly_mean .= sediment_load_yearly_mean ./ (final_year - start_year + 1)

    return sediment_load_yearly_mean
end

function yearly_mean_sediment_load_whole_area(
    df,
    start_year::Int,
    final_year::Int,
    each_year_timing,
    tag::Symbol
    )

    flow_size = length(df[df.T .== 0, :I])

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean, flow_size,
	df, start_year, final_year, each_year_timing,
	tag)

    return sediment_load_yearly_mean
end

function make_graph_yearly_mean_suspended_load(
    start_year::Int,
    final_year::Int,
    each_year_timing,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    flow_size = length(df_vararg[1][df_vararg[1].T .== 0, :I])

    title_s = string(start_year, "-", final_year)
    x_label = "Distance from the Estuary (km)"
    y_label = "Suspended Load (m³/year)"

    if japanese==true 
        title_s = string(start_year, "-", final_year)
        x_label="河口からの距離 (km)"
        y_label="浮遊砂量 (m³/年)"
    end
    
    p = plot(
    	title=title_s,
	xlabel=x_label,
	xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
	ylims=(0, 5e6),
	legend=:outerright
        )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)

    X = [0.2*(i-1) for i in 1:flow_size]    
    
    for i in 1:N
    
        sediment_load_yearly_mean = zeros(Float64, flow_size)

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    df_vararg[i],
            start_year,
            final_year,
            each_year_timing,
	    :Qsall
        )
        
        legend_label = string("Case ", i)
        
        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean),
	    label=legend_label
        )

    end

    return p
    
end

function make_graph_yearly_mean_bedload(
    start_year::Int,
    final_year::Int,
    each_year_timing,
    df_vararg::Vararg{DataFrame, N};
    japanese::Bool=false
    ) where {N}

    flow_size = length(df_vararg[1][df_vararg[1].T .== 0, :I])

    title_s = string(start_year, "-", final_year)
    x_label = "Distance from the Estuary (km)"
    y_label = "Bedload (m³/year)"

    if japanese==true 
        title_s = string(start_year, "-", final_year)
        x_label="河口からの距離 (km)"
        y_label="掃流砂量 (m³/年)"
    end
    
    p = plot(
    	title=title_s,
	xlabel=x_label,
	xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
	ylims=(0, 6e4),
	legend=:outerright
        )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)

    X = [0.2*(i-1) for i in 1:flow_size]    
    
    for i in 1:N
    
        sediment_load_yearly_mean = zeros(Float64, flow_size)

        yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
	    df_vararg[i],
            start_year,
            final_year,
            each_year_timing,
	    :Qball
        )
        
        legend_label = string("Case ", i)
        
        plot!(
            p,
            X,
            reverse(sediment_load_yearly_mean),
	    label=legend_label
        )

    end

    return p
    
end

## 20230316

function sediment_load_whole_area_each_year!(
        sediment_load_each_year,
        df::DataFrame,
        target_year::Int,
        each_year_timing,
        tag::Symbol
    )
    
    for target_hour in each_year_timing[target_year][1]:each_year_timing[target_year][2]
        
        start_index,final_index=decide_index_number(target_hour)
        
        sediment_load_each_year .= sediment_load_each_year .+ df[start_index:final_index, tag]
        
    end
    
    return sediment_load_each_year
end

function core_yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean,
        flow_size::Int,
        df::DataFrame,
        start_year::Int,
        final_year::Int,
        each_year_timing,
        tag::Symbol
    )
    
    for target_year in start_year:final_year
        
        sediment_load_each_year   = zeros(Float64, flow_size)
        sediment_load_whole_area_each_year!(sediment_load_each_year,df,target_year,each_year_timing,tag)
        
        sediment_load_yearly_mean .= sediment_load_yearly_mean .+ sediment_load_each_year

    end  
    
    sediment_load_yearly_mean .= sediment_load_yearly_mean ./(final_year-start_year+1)
    
    return sediment_load_yearly_mean
    
end

function stack_yearly_mean_sediment_load_each_size_whole_area!(
        sediment_load_each_size,
        sediment_size_num::Int,
        flow_size::Int,
        df::DataFrame,
        start_year::Int,
        final_year::Int,
        each_year_timing,
        tag::Symbol
    )

    for i in 1:sediment_size_num 

        sediment_load_yearly_mean = zeros(Float64, flow_size)
        
        each_size_tag = Symbol(string(tag, @sprintf("%02i", i)))
        
        core_yearly_mean_sediment_load_whole_area!(
            sediment_load_yearly_mean,
            flow_size,
            df,
            start_year,
            final_year,
            each_year_timing,
            each_size_tag
        )
        
        sediment_load_each_size[:,i].=sediment_load_yearly_mean
    
    end
    
    reverse!(cumsum!(sediment_load_each_size,reverse!(sediment_load_each_size, dims=2), dims=2), dims=2)    
    
    return sediment_load_each_size    

end

function make_graph_particle_yearly_mean_suspended(
    start_year::Int,
    final_year::Int,
    each_year_timing,
    df::DataFrame,
    sediment_size::DataFrame;
    japanese::Bool=false
    )

    flow_size = length(df[df.T .== 0, :I])

    sediment_size_num = size(sediment_size[:, :Np], 1)

    if japanese==false
        title_s = string(start_year, "-", final_year)
        x_label = "Distance from the Estuary (km)"
        y_label = "Suspended Load (m³/year)"
        legend_t= "Size (mm)"
    elseif japanese==true 
        title_s = string(start_year, "-", final_year)
        x_label="河口からの距離 (km)"
        y_label="浮遊砂量 (m³/年)"
        legend_t= "粒径 (mm)"        
    end

    p = plot(
    	title=title_s,
    	xlabel=x_label,
    	xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
    	ylims=(0, 5e6),
    	legend=:outerright,
        label_title=legend_t,
        palette=:tab20,
        legend_title_font_pointsize=11,
        legend_font_pointsize=9
        )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)

    X = [0.2*(i-1) for i in 1:flow_size]

    sediment_load_each_size = zeros(Float64, flow_size, sediment_size_num)

    stack_yearly_mean_sediment_load_each_size_whole_area!(
        sediment_load_each_size,
        sediment_size_num,
        flow_size,
        df,
        start_year,
        final_year,
        each_year_timing,
        :Qsall
    )

    for i in 1:sediment_size_num

        plot!(
            p,
            X,
            reverse(sediment_load_each_size[:,i]),
            label = round(sediment_size[i, 3]; sigdigits=3),
            fillrange=0,
            linewidth=1
        )
        
    end

    return p

end

function make_graph_particle_yearly_mean_bedload(
    start_year::Int,
    final_year::Int,
    each_year_timing,
    df::DataFrame,
    sediment_size::DataFrame;
    japanese::Bool=false
    )

    flow_size = length(df[df.T .== 0, :I])

    sediment_size_num = size(sediment_size[:, :Np], 1)

    if japanese==false
        title_s = string(start_year, "-", final_year)
        x_label = "Distance from the Estuary (km)"
        y_label = "Bedload (m³/year)"
        legend_t= "Size (mm)"
    elseif japanese==true 
        title_s = string(start_year, "-", final_year)
        x_label="河口からの距離 (km)"
        y_label="掃流砂量 (m³/年)"
        legend_t= "粒径 (mm)"        
    end

    p = plot(
    	title=title_s,
    	xlabel=x_label,
    	xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
    	ylims=(0, 6e4),
    	legend=:outerright,
        label_title=legend_t,
        palette=:tab20,
        legend_title_font_pointsize=11,
        legend_font_pointsize=9
        )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)

    X = [0.2*(i-1) for i in 1:flow_size]

    sediment_load_each_size = zeros(Float64, flow_size, sediment_size_num)

    stack_yearly_mean_sediment_load_each_size_whole_area!(
        sediment_load_each_size,
        sediment_size_num,
        flow_size,
        df,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )

    for i in 1:sediment_size_num

        plot!(
            p,
            X,
            reverse(sediment_load_each_size[:,i]),
            label = round(sediment_size[i, 3]; sigdigits=3),
            fillrange=0,
            linewidth=1
        )
        
    end

    return p

end

function make_graph_condition_change_yearly_mean_suspended_load(
    start_year::Int,
    final_year::Int,
    each_year_timing,
    df_base::DataFrame,
    df_with_mining::DataFrame,
    df_with_dam::DataFrame,
    df_with_mining_and_dam::DataFrame;
    japanese::Bool=false
    )

    flow_size = length(df_base[df_base.T .== 0, :I])

    title_s = string("Annual mean suspended load ", start_year, "-", final_year)
    x_label = "Distance from the Estuary (km)"
    y_label = "Variation (m³/year)"
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]    

    if japanese==true 
        title_s = string("年平均浮遊砂量 ", start_year, "-", final_year)
        x_label="河口からの距離 (km)"
        y_label="変化量 (m³/年)"
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]        
    end
    
    p = plot(
    	title=title_s,
	xlabel=x_label,
	xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
	ylims=(-7e5, 7e5),
	legend=:best
        )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=3)        

    X = [0.2*(i-1) for i in 1:flow_size]    
    
    sediment_load_yearly_mean_base = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_base,
        flow_size,
        df_base,
        start_year,
        final_year,
        each_year_timing,
        :Qsall
    )

    sediment_load_yearly_mean_mining = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_mining,
        flow_size,
        df_with_mining,
        start_year,
        final_year,
        each_year_timing,
        :Qsall
    )

    sediment_load_yearly_mean_mining .=
        sediment_load_yearly_mean_mining .- sediment_load_yearly_mean_base

    sediment_load_yearly_mean_dam = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_dam,
        flow_size,
        df_with_dam,
        start_year,
        final_year,
        each_year_timing,
        :Qsall
    )

    sediment_load_yearly_mean_dam .=
        sediment_load_yearly_mean_dam .- sediment_load_yearly_mean_base

    sediment_load_yearly_mean_mining_dam = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_mining_dam,
        flow_size,
        df_with_mining_and_dam,
        start_year,
        final_year,
        each_year_timing,
        :Qsall
    )
    
    sediment_load_yearly_mean_mining_dam .=
        sediment_load_yearly_mean_mining_dam .- sediment_load_yearly_mean_base
    
    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_mining),
        label=label_s[1]
    )

    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_dam),
        label=label_s[2]
    )
    
    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_mining_dam),
        label=label_s[3]
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)
    
    return p
    
end

function make_graph_condition_change_yearly_mean_bedload(
    start_year::Int,
    final_year::Int,
    each_year_timing,
    df_base::DataFrame,
    df_with_mining::DataFrame,
    df_with_dam::DataFrame,
    df_with_mining_and_dam::DataFrame;
    japanese::Bool=false
    )

    flow_size = length(df_base[df_base.T .== 0, :I])

    title_s = string("Annual mean bedload ", start_year, "-", final_year)
    x_label = "Distance from the Estuary (km)"
    y_label = "Variation (m³/year)"
    label_s = ["by Extraction", "by Dam", "by Extraction and Dam"]    

    if japanese==true 
        title_s = string("年平均掃流砂量 ", start_year, "-", final_year)
        x_label="河口からの距離 (km)"
        y_label="変化量 (m³/年)"
        label_s = ["砂利採取", "ダム", "砂利採取とダム"]        
    end
    
    p = plot(
    	title=title_s,
	xlabel=x_label,
	xlims=(0,77.8),
        xticks=[0, 20, 40, 60, 77.8],
        ylabel=y_label,
	ylims=(-20000, 20000),
	legend=:best
        )

    hline!(p, [0], line=:black, label="", linestyle=:dash, linewidth=3)    

    X = [0.2*(i-1) for i in 1:flow_size]    
    
    sediment_load_yearly_mean_base = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_base,
        flow_size,
        df_base,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )

    sediment_load_yearly_mean_mining = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_mining,
        flow_size,
        df_with_mining,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )

    sediment_load_yearly_mean_mining .=
        sediment_load_yearly_mean_mining .- sediment_load_yearly_mean_base

    sediment_load_yearly_mean_dam = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_dam,
        flow_size,
        df_with_dam,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )

    sediment_load_yearly_mean_dam .=
        sediment_load_yearly_mean_dam .- sediment_load_yearly_mean_base

    sediment_load_yearly_mean_mining_dam = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean_mining_dam,
        flow_size,
        df_with_mining_and_dam,
        start_year,
        final_year,
        each_year_timing,
        :Qball
    )
    
    sediment_load_yearly_mean_mining_dam .=
        sediment_load_yearly_mean_mining_dam .- sediment_load_yearly_mean_base
    
    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_mining),
        label=label_s[1]
    )

    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_dam),
        label=label_s[2]
    )
    
    plot!(
        p,
        X,
        reverse(sediment_load_yearly_mean_mining_dam),
        label=label_s[3]
    )

    vline!(p, [40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=2)
    
    return p
    
end

function make_sediment_df!(
    df_sediment,
    area_index,
    data_file,
    each_year_timing,
    sediment_size,
    qsall_or_qball_symbol::Symbol
    )

    df_sediment[!, :year] = collect(1965:1999)

    #全粒径階の合計
    sediment = zeros(Float64,1999-1965+1)
    
    sediment_volume_each_year!(
        sediment,
        area_index,
        data_file,
        each_year_timing,
        qsall_or_qball_symbol
	)    

    df_sediment[!, :total] = sediment

    #区間に分けた場合
    string_sediment_size =
        string.(round.(sediment_size[:,:diameter_mm], digits=3)) .* "_mm"
    
    sediment_size_num = size(sediment_size)[1]
    for particle_class_num in 1:sediment_size_num
        sediment = zeros(Float64,1999-1965+1)
        sediment_volume_each_year!(
            sediment,
            area_index,
            data_file,
            each_year_timing,
            Symbol(
                string(
                    qsall_or_qball_symbol, Printf.@sprintf("%02i", particle_class_num)
                )
            )
        )
        df_sediment[!, string_sediment_size[particle_class_num]] = sediment
    end

    return df_sediment

end

function make_sediment_df(
    area_index,
    data_file,
    each_year_timing,
    sediment_size,
    qsall_or_qball_symbol::Symbol
    )

    df_sediment = DataFrames.DataFrame()

    make_sediment_df!(
        df_sediment,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        qsall_or_qball_symbol
    )
    
    return df_sediment

end

function make_suspended_sediment_per_year_csv(
    area_index,
    data_file,
    each_year_timing,
    sediment_size
    )

    df_suspended = DataFrames.DataFrame()

    make_sediment_df!(
        df_suspended,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        :Qsall
    )

    area_km = 778 - (area_index - 1) * 2
    
    CSV.write(
        Printf.@sprintf("./csv_data/suspended_sediment_per_year_%03i.csv", area_km),
        df_suspended
    )

end

function make_bedload_sediment_per_year_csv(
    area_index,
    data_file,
    each_year_timing,
    sediment_size
    )

    df_bedload = DataFrames.DataFrame()

    make_sediment_df!(
        df_bedload,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        :Qball
    )

    area_km = 778 - (area_index - 1) * 2
    
    CSV.write(
        Printf.@sprintf("./csv_data/bedload_sediment_per_year_%03i.csv", area_km),
        df_bedload
    )

end

function make_sediment_mean_year_df!(
    df_sediment_mean_year,
    df_sediment,
    sediment_size,
    name_df
    )

    sediment_size_num = size(sediment_size)[1]

    year_num_index =
        ((1,35), (1,10), (11, 35), (11, 20), (21, 30), (31, 35))
    
    for i in 2:length(name_df)
        for (j, year_i) in enumerate(year_num_index)
   
            df_sediment_mean_year[j, name_df[i]] = Statistics.mean(df_sediment[year_i[1]:year_i[2], i])

        end
    end

    return df_sediment_mean_year

end

function make_suspended_sediment_mean_year_csv(
    area_index,
    data_file,
    each_year_timing,
    sediment_size
    )

    df_suspended = DataFrames.DataFrame()

    make_sediment_df!(
        df_suspended,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        :Qsall
    )

    name_df = names(df_suspended)
    
    df_suspended_mean_year = DataFrames.DataFrame(
        year=["1965-1999", "1965-1974", "1975-1999", "1975-1984", "1985-1994", "1995-1999"]
    )

    for i in 2:length(name_df)

        df_suspended_mean_year[!, name_df[i]] .= 0.0
        
    end

    make_sediment_mean_year_df!(
        df_suspended_mean_year,
        df_suspended,
        sediment_size,
        name_df
    )

    area_km = 778 - (area_index - 1) * 2
    
    CSV.write(
        Printf.@sprintf("./csv_data/suspended_sediment_mean_year_%03i.csv", area_km),
        df_suspended_mean_year
    )

end

function make_bedload_sediment_mean_year_csv(
    area_index,
    data_file,
    each_year_timing,
    sediment_size
    )

    df_bedload = DataFrames.DataFrame()

    make_sediment_df!(
        df_bedload,
        area_index,
        data_file,
        each_year_timing,
        sediment_size,
        :Qball
    )

    name_df = names(df_bedload)
    
    df_bedload_mean_year = DataFrames.DataFrame(
        year=["1965-1999", "1965-1974", "1975-1999", "1975-1984", "1985-1994", "1995-1999"]
    )

    for i in 2:length(name_df)

        df_bedload_mean_year[!, name_df[i]] .= 0.0
        
    end

    make_sediment_mean_year_df!(
        df_bedload_mean_year,
        df_bedload,
        sediment_size,
        name_df
    )

    area_km = 778 - (area_index - 1) * 2
    
    CSV.write(
        Printf.@sprintf("./csv_data/bedload_sediment_mean_year_%03i.csv", area_km),
        df_bedload_mean_year
    )

end

end
