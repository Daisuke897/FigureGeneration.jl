#    Copyright (C) 2022  Daisuke Nakahara

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

module FigureGeneration

using Plots

function default_setting_plots()
pyplot(fontfamily="IPAexGothic")

default(tickfontsize=18, legend_font_pointsize=13,
    titlefontsize=13, guidefontsize=18,
    legend_title_font_pointsize=13, dpi=300,
    grid=false, framestyle=:box)
end
export default_setting_plots

#include("graph_data.jl")
#using .GraphData

include("general_graph_module.jl")
#using .GeneralGraphModule

include("rmse.jl")
using .RMSE
export
    make_RMSE_fluctuation_graph_each_ja,
    make_RMSE_csv

include("riverbed_graph.jl")
using .RiverbedGraph
export
    comparison_final_average_riverbed_ja,
    comparison_final_average_riverbed_en,
    difference_final_average_riverbed_ja,
    difference_final_average_riverbed_en,
    graph_cumulative_change_in_riverbed_ja,
    graph_cumulative_change_in_riverbed_en,
    observed_riverbed_average_whole_each_year,
    observed_riverbed_average_section_each_year,
    graph_measured_rb_crossing_1_year_en,
    graph_simulated_rb_crossing

include("particle_size.jl")
using .ParticleSize
export
    graph_ratio_simulated_particle_size_dist_ja,
    graph_ratio_simulated_particle_size_dist_en

include("sediment_load.jl")
using .SedimentLoad
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
    make_graph_yearly_mean_suspended_load_3_conditions,
    make_graph_yearly_mean_bedload_3_conditions,
    sediment_volume_each_year,
    particle_suspended_volume_each_year,
    particle_bedload_volume_each_year

end
