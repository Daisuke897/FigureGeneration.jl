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
    ..GeneralGraphModule

export
    make_graph_sediment_load_each_year_diff_scale_ja,
    make_graph_sediment_load_each_year_diff_scale_en,
    make_graph_sediment_load_each_year_same_scale_ja,
    make_graph_sediment_load_each_year_same_scale_en,
    make_graph_suspended_volume_flow_dist,
    make_graph_bedload_volume_flow_dist,
    make_graph_sediment_volume_flow_dist,
    make_graph_yearly_mean_suspended_load,
    make_graph_yearly_mean_bedload,
    make_graph_yearly_mean_suspended_load_3_conditions,
    make_graph_yearly_mean_bedload_3_conditions

#特定位置の各年の年間掃流砂量の配列を出力する関数
function bedload_sediment_volume_each_year!(
    bedload_sediment, area_index::Int, data_file::DataFrame, each_year_timing
    )

    area_meter = 200 * (area_index - 1)

    for i in 1:(1999-1965+1)
        target_year=1965+i-1
        bedload_sediment[i]=sum(
	    data_file[data_file.I .== area_meter, :Qball][each_year_timing["$target_year"][1]+1:each_year_timing["$target_year"][2]+1]
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
	    data_file[data_file.I .== area_meter, :Qsall][each_year_timing["$target_year"][1]+1:each_year_timing["$target_year"][2]+1]
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

#-------------

#function sediment_volume_flow_dist(
#    data_file::DataFrame, target_year::Int,
#    symbol_name::Symbol, each_year_timing)

#    flow_size = length(data_file[data_file.T .== 0, :I])

#    sediment_vol_flow_dist = zeros(Float64, flow_size)

#    sediment_volume_flow_dist!(
#        sediment_vol_flow_dist, data_file,
#        target_year, flow_size, symbol_name,
#	each_year_timing)

#    return sediment_vol_flow_dist
#end

#function sediment_volume_flow_dist!(
#    sediment_vol_flow_dist, data_file::DataFrame,
#    target_year::Int, flow_size::Int,
#    symbol_name::Symbol, each_year_timing)

#    for i in 1:flow_size
#        sediment_vol_flow_dist[i] = sum(
#            data_file[data_file.I .== (200 * (i - 1)), symbol_name][each_year_timing[string(target_year)][1]+1:each_year_timing[string(target_year)][2]+1]
#            )
#    end

#    return sediment_vol_flow_dist
#end

#-------------------

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

#3つの条件を重ねられるのか。。。

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

    for target_hour in each_year_timing["$target_year"][1]:each_year_timing["$target_year"][2]
        start_index, final_index = decide_index_number(target_hour)
        sediment_load_each_year .= sediment_load_each_year .+ df[start_index:final_index, tag]
    end

    return sediment_load_each_year
end

function sediment_load_whole_area_each_year(
    df,
    target_year::Int, each_year_timing, tag::Symbol
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
    df, start_year::Int, final_year::Int,
    each_year_timing, tag::Symbol)

    flow_size = length(df[df.T .== 0, :I])

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean, flow_size,
	df, start_year, final_year, each_year_timing,
	tag)

    return sediment_load_yearly_mean
end

function make_graph_yearly_mean_suspended_load(
    df, label::String, start_year::Int, final_year::Int,
    each_year_timing)

    flow_size = length(df[df.T .== 0, :I])

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean, flow_size,
	df, start_year, final_year, each_year_timing,
	:Qsall)

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(collect(0:0.2:77.8),
        reverse(sediment_load_yearly_mean),
	title=string(start_year, "-", final_year),
	xlabel="Distance from the Estuary (km)",
        ylabel="Yearly Mean\nSuspended Load (m³/year)",
	xlims=(0,77.8),
	ylims=(0, 4e6),
	legend=:bottomright,
	label=label)

end

function make_graph_yearly_mean_bedload(
    df, label::String, start_year::Int, final_year::Int,
    each_year_timing)

    flow_size = length(df[df.T .== 0, :I])

    sediment_load_yearly_mean = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean, flow_size,
	df, start_year, final_year, each_year_timing,
	:Qball)

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(collect(0:0.2:77.8),
        reverse(sediment_load_yearly_mean),
	title=string(start_year, "-", final_year),
	xlabel="Distance from the Estuary (km)",
        ylabel="Yearly Mean\nBedload (m³/year)",
	xlims=(0,77.8),
	ylims=(0, 5e4),
	legend=:bottomright,
	label=label)

end

function make_graph_yearly_mean_suspended_load_3_conditions(
    df1, df2, df3,
    label1::String, label2::String, label3::String,
    start_year::Int, final_year::Int,
    each_year_timing)

    flow_size = length(df1[df1.T .== 0, :I])

    sediment_load_yearly_mean1 = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean1, flow_size,
	df1, start_year, final_year, each_year_timing,
	:Qsall)

    sediment_load_yearly_mean2 = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean2, flow_size,
	df2, start_year, final_year, each_year_timing,
	:Qsall)

    sediment_load_yearly_mean3 = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean3, flow_size,
	df3, start_year, final_year, each_year_timing,
	:Qsall)

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(collect(0:0.2:77.8),
        [reverse(sediment_load_yearly_mean1),
	    reverse(sediment_load_yearly_mean2),
	    reverse(sediment_load_yearly_mean3)],
	title=string(start_year, "-", final_year),
	xlabel="Distance from the Estuary (km)",
        ylabel="Yearly Mean\nSuspended Load (m³/year)",
	xlims=(0, 77.8),
	ylims=(0, 4e6),
	legend=:bottomright,
	label=[label1 label2 label3])

end

function make_graph_yearly_mean_bedload_3_conditions(
    df1, df2, df3,
    label1::String, label2::String, label3::String,
    start_year::Int, final_year::Int,
    each_year_timing)

    flow_size = length(df1[df1.T .== 0, :I])

    sediment_load_yearly_mean1 = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean1, flow_size,
	df1, start_year, final_year, each_year_timing,
	:Qball)

    sediment_load_yearly_mean2 = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean2, flow_size,
	df2, start_year, final_year, each_year_timing,
	:Qball)

    sediment_load_yearly_mean3 = zeros(Float64, flow_size)

    yearly_mean_sediment_load_whole_area!(
        sediment_load_yearly_mean3, flow_size,
	df3, start_year, final_year, each_year_timing,
	:Qball)

    vline([40.2,24.4,14.6], line=:black, label="", linestyle=:dot, linewidth=3)
    plot!(collect(0:0.2:77.8),
        [reverse(sediment_load_yearly_mean1),
	    reverse(sediment_load_yearly_mean2),
	    reverse(sediment_load_yearly_mean3)],
	title=string(start_year, "-", final_year),
	xlabel="Distance from the Estuary (km)",
        ylabel="Yearly Mean\nBedload (m³/year)",
	xlims=(0, 77.8),
	ylims=(0, 5e4),
	legend=:topleft,
	label=[label1 label2 label3])

end

end