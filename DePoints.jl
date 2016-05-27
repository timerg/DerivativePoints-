# http://mth229.github.io/derivatives.html
# forward difference
# Spline-Interpolation
# Comparing with Julia built-in function
# Comparing with Origin results

using DataFrames
using Gadfly
# using Dierckx
using Interpolations

# data = readtable("./IdVsurface_1030_nw7andnw8_PBS.txt", skipstart=1, separator= '\t', header=true)
data = readtable("./IdVsurface_1030_2-7&2-8_PBS_Vg=2v.txt", skipstart=1, separator= '\t', header=true)
input = DataFrame(Vsf = data[:Vsurface_3_2_], Id8 = data[:Id2_8_2_2_], Id7 = data[:Id2_7_4_2_])  # data is the 2nd col

plot0 = plot(layer(input, x = "Vsf", y = "Id8", Geom.point, Geom.line, Theme(default_color=colorant"green")),
            layer(input, x = "Vsf", y = "Id7", Geom.point, Geom.line, Theme(default_color=colorant"deepskyblue")),
             Guide.manual_color_key("Nw", ["Nw2-8", "Nw2-7"], ["green", "deepskyblue"]),
             Scale.y_log10,
             Guide.ylabel("Id(A)"),
             Guide.xlabel("Vg(V)")
            )
### The simplest way of "finding the tangent line"
# Example
f(x) = 2 - x^2
c = -0.75
sec_line(h) = x -> f(c) + (f(c + h) - f(c))/h * (x - c)
ex1plot = plot([f, sec_line(1), sec_line(.75), sec_line(.5), sec_line(.25)], -1, 1)

# forward difference
derv1_8 = Float64[1 : 21]
for i in collect(2 : 20)
    derv1_8[i] = (input[:Id8][i + 1] - input[:Id8][i - 1])/(input[:Vsf][i] - input[:Vsf][i - 1])
end
derv1_8[21] = (input[:Id8][21] - input[:Id8][20])/(input[:Vsf][21] - input[:Vsf][20])
derv1_8[1] = (input[:Id8][2] - input[:Id8][1])/(input[:Vsf][2] - input[:Vsf][1])

plot1 = plot(input, x = "Vsf", y = derv1_8,Geom.point, Geom.line, Scale.y_log10)

### Spline-Interpolation

# sIt(x, x1, x2) = (x - x1)/(x2 - x1)
# sIq(x, x1, x2, y1, y2 ) = (1 - sIt(x, x1, x2))*y1 + sIt(x, x1, x2)*y2 + sIt(x, x1, x2)*(1 - sIt(x, x1, x2))*(a*(1 - sIt(x, x1, x2)) + b*sIt(x, x1, x2))
# sIa(k, x1, x2, y1, y2) = k*(x2 - x1) - (y2 - y1)
# sIb(k2, x1, x2, y1, y2) = -k

###  Julia function(Spline-Interpolation)
itp = interpolate([input[:Vsf] input[:Id8] input[:Id7]], BSpline(Quadratic(Reflect())), OnCell())
input_new = DataFrame(
    Vsf = Array{Float64, 1}(zeros(201))
    , Id8 = Array{Float64, 1}(zeros(201))
    , Id7 = Array{Float64, 1}(zeros(201))
)
for i in collect(1:0.1:21)
    input_new[:Vsf][i*10-9] = itp[i, 1]
    input_new[:Id8][i*10-9] = itp[i, 2]
    input_new[:Id7][i*10-9] = itp[i, 3]
end


derv_new_8 = DataArray{Float64, 1}(zeros(201))
# derv_new_8 = DataArray{Float64}(NA)
derv_new_7 = DataArray{Float64, 1}(zeros(201))
for i in collect(2 : 200)
    derv_new_8[i] = (input_new[:Id8][i + 1] - input_new[:Id8][i - 1])/(input_new[:Vsf][i] - input_new[:Vsf][i - 1])
    derv_new_7[i] = (input_new[:Id7][i + 1] - input_new[:Id7][i - 1])/(input_new[:Vsf][i] - input_new[:Vsf][i - 1])
end
# derv_new_8[201] = (input_new[:Id8][201] - input_new[:Id8][200])/(input_new[:Vsf][201] - input_new[:Vsf][200])
# derv_new_8[1] = (input_new[:Id8][2] - input_new[:Id8][1])/(input_new[:Vsf][2] - input_new[:Vsf][1])
# derv_new_7[201] = (input_new[:Id7][201] - input_new[:Id7][200])/(input_new[:Vsf][201] - input_new[:Vsf][200])
# derv_new_7[1] = (input_new[:Id7][2] - input_new[:Id7][1])/(input_new[:Vsf][2] - input_new[:Vsf][1])



plot2 = plot(layer(input_new, x = "Vsf", y = derv_new_8, Geom.line, Theme(default_color=colorant"green", line_width=3px)),
             layer(input_new, x = "Vsf", y = derv_new_7, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3px)),
             Guide.manual_color_key("Nw", ["Nw2-8", "Nw2-7"], ["green", "deepskyblue"]),
             Scale.y_log10,
             Guide.ylabel("Id(A)"),
             Guide.xlabel("Vg(V)")
            )



#
ticks = [-6, -5, -4]
ticksx = [-0.5, 0, 1, 2, 3, 3.5]
plot_Id_Vsf = plot(layer(input_new, x = "Vsf", y = "Id8", Geom.line, Theme(default_color=colorant"green", line_width=3px)),
             layer(input_new, x = "Vsf", y = "Id7", Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3px)),
             Guide.manual_color_key("Nw", ["NwA", "NwB"], ["green", "deepskyblue"]),
             Scale.y_log10,
             Guide.yticks(ticks = ticks),
             Guide.xticks(ticks = ticksx),
             Guide.ylabel("Id(A)"),
             Guide.xlabel("Vg(V)")
            )

plot_gbs_Id = plot(layer(input_new, x = "Id8", y = derv_new_8, Geom.line, Theme(default_color=colorant"green", line_width=3px)),
             layer(input_new, x = "Id7", y = derv_new_7, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3px)),
             Guide.manual_color_key("Nw", ["NwA", "NwB"], ["green", "deepskyblue"]),
             Scale.y_log10,
             Scale.x_log10,
             Guide.yticks(ticks= ticks),
             Guide.ylabel("Tc(dA/dV)"),
             Guide.xlabel("Id(A)")
            )

plot_gbs_Vsf = plot(layer(input_new, x = "Vsf", y = derv_new_8, Geom.line, Theme(default_color=colorant"green", line_width=3px)),
             layer(input_new, x = "Vsf", y = derv_new_7, Geom.line, Theme(default_color=colorant"deepskyblue", line_width=3px)),
             Guide.manual_color_key("Nw", ["NwA", "NwB"], ["green", "deepskyblue"]),
             Scale.y_log10,
             Guide.yticks(ticks= ticks),
             Guide.ylabel("Transconductance(dA/dV)"),
             Guide.xlabel("Vg(V))")
            )

draw(SVG("./Id_Vsf.svg", 12cm, 8cm), plot_Id_Vsf)
draw(SVG("./gbs_Id.svg", 12cm, 8cm), plot_gbs_Id)
draw(SVG("./gbs_Vsf.svg", 12cm, 8cm), plot_gbs_Vsf)
