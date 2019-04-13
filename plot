#!/usr/bin/python
# encoding: utf-8

import os
import sys

def plot_graph(name,topology,list_rsa,function,lang):
    f = open(name+"-"+topology+".plot","w")
    f.write("set terminal pdf enhanced color font \"Times, 16\"\n")
    f.write("set key font \"Times, 13\"\n")
    f.write("set key tmargin\n")
    f.write("set key center\n")
    f.write("set key horiz\n")
    f.write("set key width 2\n")
    f.write("unset label\n")
    f.write("set xtic auto\n")
    f.write("set ytic auto\n")
    f.write("set xlabel \"Load\"\n")
    function(f,lang)
    f.write("set out '"+name+"-"+topology+".pdf'\n")
    f.write("plot ")
    i=1
    for rsa in sorted(list_rsa):
        if os.path.isfile(rsa+"-"+topology+"-"+name+".dat"):
            f.write("\""+rsa+"-"+topology+"-"+name+".dat\" using 1:2:3 title \""+rsa+"\" w yerrorlines lt "+str(i)+" lw 2, ")
            i+=1
    f.close()
    if i > 1:
        os.system("gnuplot "+name+"-"+topology+".plot")

def mbbr(f,lang):
    f.write("set logscale y\n")
    f.write("set format y \"10^{%T}\"\n")
    if lang == "pt":
        f.write("set ylabel \"Razão Bloqueio Banda\"\n")
    else:
        f.write("set ylabel \"Bandwidth Block Ratio\"\n")

def avgcrosstalk(f,lang):
    if lang == "pt":
        f.write("set ylabel \"Crosstalk médio (dB)\"\n")
    else:
        f.write("set ylabel \"Average Crosstalk (dB)\"\n")
    

def avgbps(f,lang):
    if lang == "pt":
        f.write("set ylabel \"Média de bits por símbolo\"\n")
    else:
        f.write("set ylabel \"Average Bits per Symbol\"\n")

def ee(f,lang):
    if lang == "pt":
        f.write("set ylabel \"Eficiência Energética (Mbits/Joule)\"\n")
    else:
        f.write("set ylabel \"Energy Eficiency (Mbits/Joule)\"\n")

def pc(f,lang):
    if lang == "pt":
        f.write("set ylabel \"Consumo Energético (kJ)\"\n")
    else:
        f.write("set ylabel \"Energy Consumption (kJ)\"\n")

def dd(f,lang):
    if lang == "pt":
        f.write("set ylabel \"Atraso Diferencial\"\n")
    else:
        f.write("set ylabel \"Differential Delay (ms)\"\n")

def plot_multipath(name,topology,rsa,lang):
    f = open(name+"-"+topology+"-"+rsa+".plot","w")
    f.write("set terminal pdf enhanced color font \"Times, 16\"\n")
    f.write("set autoscale\n")
    f.write("set key font \"Times, 13\"\n")
    f.write("set style data histograms\n")
    f.write("set style histogram rowstacked\n")
    f.write("set style fill solid 1.0 border -1\n")
    f.write("set key tmargin\n")
    f.write("set key center\n")
    f.write("set key horiz\n")
    f.write("unset label\n")
    f.write("set xtic auto\n")
    f.write("set ytic auto\n")
    f.write("set xlabel \"Carga\"\n")
    f.write("set ylabel \"Número de caminhos\"\n")
    f.write("set out '"+name+"-"+topology+"-"+rsa+".pdf'\n")
    f.write("set format x \"%.0f\"\n")
    if lang == "pt":
        f.write("plot \""+rsa+"-"+topology+"-"+name+".dat\" using 2 t \"2 Caminhos\", '' using 3 t \"3 Caminhos\", '' using 4 t \"4 Caminhos\",'' using 5:xtic(1) t \"5 Caminhos\"")
    else: 
        f.write("plot \""+rsa+"-"+topology+"-"+name+".dat\" using 2 t \"2 Paths\", '' using 3 t \"3 Paths\", '' using 4 t \"4 Paths\",'' using 5:xtic(1) t \"5 Paths\"")
    
    f.close()
    os.system("gnuplot "+name+"-"+topology+"-"+rsa+".plot")

def plot(lang):
    for topology in os.listdir('xml/topologies'):
        r = []
        for rsa in os.listdir('xml/rsa'):
            r.append(rsa[:-4])
        plot_graph("mbbr",topology[:-4],r,mbbr,lang)
        plot_graph("avgcrosstalk",topology[:-4],r,avgcrosstalk,lang)
        plot_graph("avgbps",topology[:-4],r,avgbps,lang)
        plot_graph("ee",topology[:-4],r,ee,lang)
        plot_graph("pc",topology[:-4],r,pc,lang)
        plot_graph("dd",topology[:-4],r,dd,lang)
        for rsa in r:
            if os.path.isfile(rsa+"-"+topology[:-4]+"-multipath.dat"): 
                plot_multipath("multipath",topology[:-4],rsa,lang)

def plot_multicore_graph(name,graph_name,rsa,dict_topology,function,lang):
    for topo, cores in dict_topology.iteritems():
        f = open(name+"-"+topo+"-"+rsa+".plot","w")
        f.write("set terminal pdf enhanced color font \"Times, 16\"\n")
        f.write("set autoscale\n")
        f.write("set key font \"Times, 13\"\n")
        f.write("set key tmargin\n")
        f.write("set key center\n")
        f.write("set key horiz\n")
        f.write("unset label\n")
        f.write("set xtic auto\n")
        f.write("set ytic auto\n")
        f.write("set xlabel \"Load\"\n")
        function(f,lang)
        f.write("set out '"+name+"-"+rsa+"-"+topo+".pdf'\n")
        f.write("plot ")
        i=1
        for c in sorted(cores, cmp=compare_cores):
            if os.path.isfile(rsa+"-"+topo+c+"-"+graph_name+".dat"):
                if lang == "pt":
                    f.write("\""+rsa+"-"+topo+c+"-"+graph_name+".dat\" using 1:2:3 title \""+c+" núcleos\" w yerrorlines lt "+str(i)+" lw 2, ")
                else:
                    f.write("\""+rsa+"-"+topo+c+"-"+graph_name+".dat\" using 1:2:3 title \""+c+" cores\" w yerrorlines lt "+str(i)+" lw 2, ")
                i+=1
        f.close()
        if i > 1:
            os.system("gnuplot "+name+"-"+topo+"-"+rsa+".plot")


def plot_multicore(lang):
    for rsa in os.listdir('xml/rsa'):
        s = {"usa": [], "nsf": []}
        for topology in os.listdir('xml/topologies'):
            s[topology[:3]].append(topology[3:-4])
        for t in s:
            plot_multicore_graph("multicore-mbbr","mbbr",rsa[:-4],s,mbbr,lang)
            plot_multicore_graph("multicore-ee","ee",rsa[:-4],s,ee,lang)
            plot_multicore_graph("multicore-pc","pc",rsa[:-4],s,pc,lang)
            plot_multicore_graph("multicore-avgbps","avgbps",rsa[:-4],s,avgbps,lang)
            plot_multicore_graph("multicore-avgcrosstalk","avgcrosstalk",rsa[:-4],s,avgcrosstalk,lang)
            plot_multicore_graph("multicore-dd","dd",rsa[:-4],s,dd,lang)

def compare_cores(a,b):
    if len(a) == len(b):
        if a < b:
            return -1
        elif a == b:
            return 0
        else:
            return 1
    elif len(a) < len(b):
        return -1
    elif len(a) > len(b):
        return 1
        
lang = sys.argv[1]
if sys.argv[1]!="clean":
    os.system("rm -rf *.pdf")
    os.system("rm -rf *.plot")
elif sys.argv[1]!="":
    lang = sys.argv[1]
else:
    lang = "en"

plot(lang)
plot_multicore(lang)
