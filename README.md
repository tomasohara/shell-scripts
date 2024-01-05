## Information on shell-scripts collection

See [README.txt](README.txt) for overview and historical information. Also, see
[mezcla](https://github.com/tomasohara/mezcla) for a companion package of Python
scripts.

## Installation

For simplicity, the following installs the software into your home directory.

```
cd
git clone https://github.com/tomasohara/shell-scripts
cd shell-scripts
pip install --requirement requirements.txt
sudo apt-get install $(grep -v ^# required-packages.txt)
```

## Optional installation

The default installation just covers the common packages used by most scripts. Some scripts here and in the mezcla require additional packages. In addition, some packages require post-installation steps. These can be installed as follows:

```
# Install Mezcal with optional packages, and get optional ones for shell-scripts
cd
git clone https://github.com/tomasohara/mezcla
pip install --verbose $(perl -pe 's/^#opt#\s*//;' mezcla/requirements.txt | grep -v '^#')
sudo apt-get install $(perl -pe 's/^#opt#\s*//;' shell-scripts/required-packages.txt | grep -v '^#')

# Post installation stuff
python -m bash_kernel.install
python -m nltk.downloader punkt averaged_perceptron_tagger
python -m spacy download en_core_web_lg
```
