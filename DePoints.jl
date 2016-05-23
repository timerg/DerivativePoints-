# http://mth229.github.io/derivatives.html
# forward difference
# Spline-Interpolation
# Comparing with Julia built-in function
# Comparing with Origin results

using DataFrames
using Gadfly

data = readtable("./IdVsurface_1030_nw7andnw8_PBS.txt", skipstart=1, separator= '\t', header=true)
input = DataFrame(Vsf = data[:Vsurface_3_2_], Id8 = data[:Id2_8_2_2_], Id7 = data[:Id2_7_4_2_])  # data is the 2nd col

plot0 = plot(layer(input, x = "Vsf", y = "Id8", Geom.point, Geom.line, Theme(default_color=colorant"green")),
            layer(input, x = "Vsf", y = "Id7", Geom.point, Geom.line, Theme(default_color=colorant"deepskyblue")),
             Guide.manual_color_key("Nw", ["Nw2-8", "Nw2-7"], ["green", "deepskyblue"]),
             Scale.y_log10
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

#







#