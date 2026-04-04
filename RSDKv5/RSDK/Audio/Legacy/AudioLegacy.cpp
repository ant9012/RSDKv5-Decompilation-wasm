
static float currentMusicSpeedFix = 1.0f;

int32 RSDK::Legacy::globalSFXCount = 0;
int32 RSDK::Legacy::stageSFXCount  = 0;

int32 RSDK::Legacy::musicVolume       = 0;
int32 RSDK::Legacy::sfxVolume         = 0;
int32 RSDK::Legacy::bgmVolume         = 0;
int32 RSDK::Legacy::musicCurrentTrack = 0;
int32 RSDK::Legacy::musicChannel      = 0;

float RSDK::Legacy::v4::musicRatio = 0.0f;

RSDK::Legacy::TrackInfo RSDK::Legacy::musicTracks[LEGACY_TRACK_COUNT];

char RSDK::Legacy::v4::sfxNames[SFX_COUNT][0x40];

void RSDK::Legacy::SetMusicTrack(const char *filePath, uint8 trackID, bool32 loop, uint32 loopPoint)
{
    TrackInfo *track = &musicTracks[trackID & 0xF];

    // StrCopy(track->fileName, "Data/Music/");
    // StrAdd(track->fileName, filePath);
    StrCopy(track->fileName, filePath);
    track->trackLoop = loop;
    track->loopPoint = loopPoint;
}

static float GetAudioSpeedFix(const char* filepath) {
    RSDK::FileInfo info;
    float speed = 1.0f; // Strictly default to 1.0x (normal speed)
    
    if (RSDK::LoadFile(&info, filepath, RSDK::FMODE_RB)) {
        
        // CRITICAL FIX 1: Initialize the buffer to all zeros!
        // This prevents reading leftover ghost memory from the previous song.
        uint8 buffer[128] = {0}; 
        RSDK::ReadBytes(&info, buffer, sizeof(buffer));
        RSDK::CloseFile(&info);
        
        // --- OGG VORBIS CHECK ---
        if (buffer[0] == 'O' && buffer[1] == 'g' && buffer[2] == 'g' && buffer[3] == 'S') {
            for (int i = 0; i < sizeof(buffer) - 15; i++) {
                
                // CRITICAL FIX 2: Check for 0x01 before 'v' to guarantee we 
                // are reading the true ID header, not a comment tag or random data.
                if (buffer[i] == 0x01 && buffer[i+1] == 'v' && buffer[i+2] == 'o' && 
                    buffer[i+3] == 'r' && buffer[i+4] == 'b' && buffer[i+5] == 'i' && buffer[i+6] == 's') {
                    
                    // CRITICAL FIX 3: Cast to uint32 to prevent integer overflow
                    uint32 sampleRate = (uint32)buffer[i+12] | ((uint32)buffer[i+13] << 8) | 
                                        ((uint32)buffer[i+14] << 16) | ((uint32)buffer[i+15] << 24);
                    
                    // STRICT WHITELIST: Only change speed if it is exactly 48000Hz.
                    if (sampleRate == 48000) {
                        speed = 48000.0f / 44100.0f;
                    }
                    break; // Stop searching once we find the header
                }
            }
        }
        // --- WAV CHECK ---
        else if (buffer[0] == 'R' && buffer[1] == 'I' && buffer[2] == 'F' && buffer[3] == 'F') {
            uint32 sampleRate = (uint32)buffer[24] | ((uint32)buffer[25] << 8) | 
                                ((uint32)buffer[26] << 16) | ((uint32)buffer[27] << 24);
            
            if (sampleRate == 48000) {
                speed = 48000.0f / 44100.0f;
            }
        }
    }
    
    return speed;
}

int32 RSDK::Legacy::PlayMusic(int32 trackID)
{
    TrackInfo *track = &musicTracks[trackID & 0xF];

    if (!track->fileName[0]) {
        StopChannel(musicChannel);
    }
    else {
        uint32 startPos = 0;
        if (RSDK::Legacy::v4::musicRatio) {
            startPos                     = (uint32)(GetChannelPos(musicChannel) * RSDK::Legacy::v4::musicRatio);
            RSDK::Legacy::v4::musicRatio = 0.0;
        }

        int32 loopPoint = track->loopPoint;
        if (!loopPoint && track->trackLoop)
            loopPoint = 1;

        // --- DYNAMIC AUDIO SPEED PATCH ---
        // Automatically check this specific track's sample rate
        currentMusicSpeedFix = GetAudioSpeedFix(track->fileName);

        musicCurrentTrack = trackID;
        // Make sure the last parameter here is 'false' so it loads synchronously
        musicChannel      = PlayStream(track->fileName, musicChannel, startPos, loopPoint, false);
        musicVolume       = 100;

        // Apply the dynamic speed correction immediately
        SetChannelAttributes(musicChannel, 1.0f, 0.0f, currentMusicSpeedFix);
    }

    return musicChannel;
}

void RSDK::Legacy::SetMusicVolume(int32 volume)
{
    musicVolume = CLAMP(volume, 0, 100);
    // Change the update loop to use our dynamic global variable
    SetChannelAttributes(musicChannel, musicVolume / 100.0f, 0.0f, currentMusicSpeedFix);
}

void RSDK::Legacy::v4::SwapMusicTrack(const char *filePath, uint8 trackID, uint32 loopPoint, uint32 ratio)
{
    TrackInfo *track = &musicTracks[trackID & 0xF];

    if (StrLength(filePath) <= 0) {
        StopChannel(musicChannel);
    }
    else {
        // StrCopy(track->fileName, "Data/Music/");
        // StrAdd(track->fileName, filePath);
        StrCopy(track->fileName, filePath);
        track->trackLoop = true;
        track->loopPoint = loopPoint;
        musicRatio       = ratio / 10000.0f;

        PlayMusic(trackID);
    }
}

void RSDK::Legacy::LoadSfx(char *filename, uint8 slot, uint8 scope)
{
    if (sfxList[slot].scope == SCOPE_NONE)
        LoadSfxToSlot(filename, slot, 1, scope);
}

void RSDK::Legacy::v3::SetSfxAttributes(int32 channelID, int32 loop, int8 pan)
{
    if (channelID < 0 || channelID >= CHANNEL_COUNT)
        return;

    if (channels[channelID].state == CHANNEL_SFX) {
        RSDK::SetChannelAttributes(channelID, 1.0, pan / 100.0f, 1.0);
        if (loop != -1)
            channels[channelID].loop = loop ? 0 : -1;
    }
}

void RSDK::Legacy::v4::SetSfxName(const char *sfxName, int32 sfxID)
{
    int32 sfxNameID   = 0;
    int32 soundNameID = 0;
    while (sfxName[sfxNameID]) {
        if (sfxName[sfxNameID] != ' ')
            sfxNames[sfxID][soundNameID++] = sfxName[sfxNameID];
        ++sfxNameID;
    }
    sfxNames[sfxID][soundNameID] = 0;

    PrintLog(PRINT_NORMAL, "Set SFX (%d) name to: %s", sfxID, sfxName);
}

void RSDK::Legacy::v4::SetSfxAttributes(int32 sfxID, int32 loop, int8 pan)
{
    for (int32 c = 0; c < CHANNEL_COUNT; ++c) {
        if (channels[c].soundID == sfxID && channels[c].state == CHANNEL_SFX) {
            
            // FIX: Replaced 'pan / 100.0f' with '0.0f' to prevent the WebAudio extreme-pan mute bug
            RSDK::SetChannelAttributes(c, 1.0, 0.0f, 1.0);
            
            if (loop != -1)
                channels[c].loop = loop ? 0 : -1;
        }
    }
}

#if RETRO_USE_MOD_LOADER
char RSDK::Legacy::v3::globalSfxNames[SFX_COUNT][0x40];
char RSDK::Legacy::v3::stageSfxNames[SFX_COUNT][0x40];

void RSDK::Legacy::v3::SetSfxName(const char *sfxName, int32 sfxID, bool32 global)
{
    char *sfxNamePtr = global ? globalSfxNames[sfxID] : stageSfxNames[sfxID];

    int32 sfxNamePos = 0;
    int32 sfxPtrPos  = 0;
    uint8 mode       = 0;
    while (sfxName[sfxNamePos]) {
        if (sfxName[sfxNamePos] == '.' && mode == 1)
            mode = 2;
        else if ((sfxName[sfxNamePos] == '/' || sfxName[sfxNamePos] == '\\') && !mode)
            mode = 1;
        else if (sfxName[sfxNamePos] != ' ' && mode == 1)
            sfxNamePtr[sfxPtrPos++] = sfxName[sfxNamePos];
        ++sfxNamePos;
    }
    sfxNamePtr[sfxPtrPos] = 0;
    PrintLog(PRINT_NORMAL, "Set %s SFX (%d) name to: %s", (global ? "Global" : "Stage"), sfxID, sfxNamePtr);
}
#endif
