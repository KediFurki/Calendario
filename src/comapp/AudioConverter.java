package comapp;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class AudioConverter {
    private static final Logger log = LogManager.getLogger(AudioConverter.class);

    public static boolean isValidWavFile(byte[] audioData) {
        if (audioData == null || audioData.length < 12) {
            return false;
        }
        String riff = new String(audioData, 0, 4);
        String wave = new String(audioData, 8, 4);
        return "RIFF".equals(riff) && "WAVE".equals(wave);
    }

    public static boolean isWavExtension(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return false;
        }
        return fileName.toLowerCase().endsWith(".wav");
    }

    public static String validateAudioFile(String fileName, byte[] audioData) {
        if (!isWavExtension(fileName)) {
            return "Only WAV files are accepted. Please convert your audio file to WAV format before uploading.";
        }
        if (!isValidWavFile(audioData)) {
            return "Invalid WAV file. The file appears to be corrupted or not a valid WAV format.";
        }
        if (audioData.length > 50 * 1024 * 1024) {
            return "File too large. Maximum file size is 50MB.";
        }
        return null;
    }
}