
namespace Legacy
{
namespace v4
{
enum RetroStates {
    ENGINE_WAIT      = 3,
    ENGINE_INITPAUSE = 5,
    ENGINE_EXITPAUSE = 6,
    ENGINE_ENDGAME   = 7,
    ENGINE_RESETGAME = 8,
};

bool32 LoadGameConfig(const char *filepath);
void ProcessEngine();

#if RETRO_USE_MOD_LOADER
void LoadGameXML(bool pal = false);
void LoadXMLWindowText(const tinyxml2::XMLElement *gameElement);
void LoadXMLVariables(const tinyxml2::XMLElement *gameElement);
void LoadXMLPalettes(const tinyxml2::XMLElement* gameElement);
void LoadXMLObjects(const tinyxml2::XMLElement* gameElement);
void LoadXMLSoundFX(const tinyxml2::XMLElement* gameElement);
void LoadXMLPlayers(const tinyxml2::XMLElement* gameElement);
void LoadXMLStages(const tinyxml2::XMLElement* gameElement);
#endif

void Connect2PVS(int32 *gameLength, int32 *itemMode);
void Disconnect2PVS();
void SendEntity(int32 *slot, int32 *active);
void SendValue(int32 *value, int32 *active);
void ReceiveEntity(int32 *slot, int32 *active);
void ReceiveValue(int32 *value, int32 *active);
void TransmitGlobal(const char *varName, int32 *value);
void ShowPromoPopup(int32 *id);
void NativePlayerWaitingAds(int32 *unused1, int32 *unused2);
void NativeWaterPlayerWaitingAds(int32 *unused1, int32 *unused2);

} // namespace v4
} // namespace Legacy
