# Chroma Resampler II Validation

The **Chroma Resampler II** IP performs chroma resampling (e.g. 4:4:4 to 4:2:2 or vice versa) on a video stream. This validation design feeds a TPG stream through the resampler and a checker compares the output data against the expected resampled values.

## Validation Configuration

| Parameter              | Value                    |
|------------------------|--------------------------|
| Input Data Width       | 32 bits                  |
| Output Data Width      | 48 bits                  |
| Interface              | Avalon-ST                |

## Validation Flow

<img width="1328" height="567" alt="image" src="https://github.com/user-attachments/assets/31d6aafb-5ed3-4aba-adc6-41c60066eb80" />
