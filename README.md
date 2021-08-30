# About

This repository contains a reference implementation of the Coding and Multi-Parameterisation of Ambisonic Sound Scenes (COMPASS) method, as presented in publication [1].

## Dependencies

This Matlab code is reliant on the following libraries:
* [alias-free STFT](https://github.com/jvilkamo/afSTFT)
* [Higher-Order-Ambisonics](https://github.com/polarch/Higher-Order-Ambisonics)
* [Spherical-Harmonic-Transform](https://github.com/polarch/Spherical-Harmonic-Transform)

Precompiled mex files of afSTFT are provided in the ./ext-lib/afSTFT directory of the repo. Please download the rest of the dependencies and add them to Matlab's search path.

## Example

The repository contains a **TEST_COMPASS.m** test script, which also serves as example usage of the reference implementation.

## Contributing

Suggestions and contributions to the code are both welcomed and encouraged. 
If you encounter any issues, please feel free to contact the developers, open a "github" issue, or submit pull requests.

## Developers

The Matlab code is developed primarily by Archontis Politis, with contributions from Leo McCormack.
The developers also maintain a free VST audio-plugin suite of the COMPASS method. More information regarding the plug-ins can be [found here](https://leomccormack.github.io/sparta-site/docs/plugins/compass-suite/).

## References

* [1] Politis, A., Tervo S., and Pulkki, V. (2018) **COMPASS: Coding and Multidirectional Parameterization of Ambisonic Sound Scenes.** IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP).

## License

This software is provided under the terms of the [GNU GPLv2 License](https://choosealicense.com/licenses/gpl-2.0/).

For full licensing terms see [LICENSE](LICENSE).
