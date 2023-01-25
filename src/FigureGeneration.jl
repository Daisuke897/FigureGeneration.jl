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
        grid=false, framestyle=:box, linewidth=2)
end

function check_dir_exist_if_no_mkdir(path_string::String)
    if isdir(path_string) == false
        mkdir(path_string)
    end
end

export default_setting_plots,
       check_dir_exist_if_no_mkdir


include("read_df_river.jl")
using .Read_df_river
export
    get_main_df,
    get_time_schedule,
    get_dict_each_year_timing,
    get_observed_riverbed_level,
    get_sediment_size,
    get_fmini,
    Section,
    Exist_riverbed_level

include("general_graph_module.jl")

include("rmse.jl")
using .RMSE
export
    make_RMSE_fluctuation_graph_each,
    make_RMSE_csv

include("riverbed_graph.jl")
using .RiverbedGraph
export
    comparison_final_average_riverbed,
    difference_final_average_riverbed,
    graph_cumulative_change_in_riverbed,
    graph_condition_change_in_riverbed,
    observed_riverbed_average_whole_each_year,
    observed_riverbed_average_section_each_year,
    graph_simulated_riverbed_fluctuation,    
    graph_measured_rb_crossing_1_year_en,
    graph_simulated_rb_crossing

include("particle_size.jl")
using .ParticleSize
export
    graph_ratio_simulated_particle_size_dist,
    graph_average_simulated_particle_size_dist,
    graph_average_simulated_particle_size_fluc,
    graph_cumulative_change_in_mean_diameter,
    graph_condition_change_in_mean_diameter

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
    make_graph_condition_change_yearly_mean_suspended_load,    
    make_graph_condition_change_yearly_mean_bedload,
    make_graph_particle_suspended_volume_each_year_ja,
    make_graph_particle_bedload_volume_each_year_ja,
    make_graph_particle_sediment_volume_each_year_ja,
    make_suspended_sediment_per_year_csv,
    make_bedload_sediment_per_year_csv,
    make_suspended_sediment_mean_year_csv,
    make_bedload_sediment_mean_year_csv

include("hydraulic_conditions.jl")
using .Hydraulic_conditions
export make_upstream_discharge_graph,
       make_downstream_water_level_graph,
       make_up_discharge_down_water_lev_graph

include("parameters.jl")
using .Parameters
export make_figure_energy_slope,
       make_figure_friction_velocity,
       make_figure_non_dimensional_shear_stress,
       params

end
