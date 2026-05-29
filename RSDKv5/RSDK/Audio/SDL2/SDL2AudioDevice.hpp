#define LockAudioDevice()   SDL_LockAudioDevice(AudioDevice::device)
#define UnlockAudioDevice() SDL_UnlockAudioDevice(AudioDevice::device)

#include <thread>

namespace RSDK
{
class AudioDevice : public AudioDeviceBase
{
public:
    static SDL_AudioDeviceID device;

    static bool32 Init();
    static void Release();

    static void FrameInit() {}

    inline static void HandleStreamLoad(ChannelInfo *channel, bool32 async)
    {
        // we remove the if/else here because we DONT use threads
            LoadStream(channel);
    }

private:
    static SDL_AudioSpec deviceSpec;

    static uint8 contextInitialized;

    static void InitAudioChannels();

    static void AudioCallback(void *data, uint8 *stream, int32 len);
};
} // namespace RSDK
