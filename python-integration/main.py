from scipy import signal
from pylab import cos, linspace, subplots, tanh
from ddeint import ddeint


def values_before_zero(t):
    # This is the "original" data that the DDE is derived from. 
    # I presume this represents the "distance" from the target point that the finger starts at
    return 1

# These constants are totally random and need to be found experimentally
# ...but there is an *intended* meaning for them from the paper.

# Represents the visual feedback delay
tao1 = 1.6
# '' for the mucular feedback delay - "proprioception" might be useful on google
tao2 = 0.5
#
a = 2
b = 1
def model(Y, t):
    return -a * tanh(Y(t - tao1) + signal.bessel(8, 0.5)[0]) - b * tanh(Y(t - tao2))

tt = linspace(0, 100, 2000)
yy = ddeint(model, values_before_zero, tt)

fig, ax = subplots(1, figsize=(4, 4))
ax.plot(tt, yy)
ax.figure.savefig("variable_delay.jpeg")