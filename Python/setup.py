from setuptools import find_packages, setup

from pathlib import Path

this_directory = Path(__file__).parent
long_description = (this_directory / "readme.md").read_text()

setup(
    name="jb_news",
    packages=find_packages(include=["jb_news"]),
    version="2.2.4",
    description="A comprehensive wrapper for JBlanked's News API, leveraging OpenAI, Machine Learning, and MQL5's Calendar.",
    author="JBlanked",
    install_requires=["requests"],
    long_description=long_description,
    long_description_content_type="text/markdown",
    license="MIT",
    url="https://jblanked.com/news/api/docs/",
)
