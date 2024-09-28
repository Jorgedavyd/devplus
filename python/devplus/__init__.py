from .rag import setup as rag
from .llm import setup as llm
from .plotter import setup as plotter

__version__ = '{{VERSION_PLACEHOLDER}}'
__author__ = 'Jorgedavyd'
__email__ = 'jorged.encyso@gmail.com'

import pynvim

@pynvim.plugin
class devplus:
    def __init__(self, nvim) -> None:
        self.nvim = nvim
        rag(self)
        llm(self)
        plotter(self)

