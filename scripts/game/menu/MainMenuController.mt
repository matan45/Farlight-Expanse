import * from "engine/Log.mt";
import * from "engine/Entity.mt";
import * from "engine/UI.mt";
import * from "engine/Audio.mt";
import * from "engine/Config.mt";
import * from "engine/Scene.mt";
import * from "engine/Input.mt";
import * from "engine/Key.mt";
import * from "engine/IUIButtonListener.mt";
import * from "engine/IUISliderListener.mt";
import * from "engine/Coroutine.mt";
import * from "engine/Timer.mt";
import * from "../../lib/math/Vec3f.mt";

@Script
public class MainMenuController implements IUIButtonListener, IUISliderListener {
    private int selfId;

    // Panel entities
    private int mainPanel;
    private int settingsPanel;
    private int fadeOverlay;

    // Audio entities
    private int menuMusic;
    private int clickSfx;

    // Button entities
    private int continueBtn;
    private int loadGameBtn;

    // Slider entities
    private int masterSlider;
    private int musicSlider;
    private int sfxSlider;
    private int ambientSlider;

    // Tabs
    private int settingsTabs;

    // State
    private bool isTransitioning;

    public function onStart(): void {
        this.selfId = Entity::self();
        this.isTransitioning = false;

        // Find UI panels
        this.mainPanel = Entity::findByName("MainPanel");
        this.settingsPanel = Entity::findByName("SettingsPanel");
        this.fadeOverlay = Entity::findByName("FadeOverlay");

        // Find audio entities
        this.menuMusic = Entity::findByName("MenuMusic");
        this.clickSfx = Entity::findByName("ButtonClickSFX");

        // Find buttons that need special handling
        this.continueBtn = Entity::findByName("ContinueBtn");
        this.loadGameBtn = Entity::findByName("LoadGameBtn");

        // Find sliders
        this.masterSlider = Entity::findByName("MasterSlider");
        this.musicSlider = Entity::findByName("MusicSlider");
        this.sfxSlider = Entity::findByName("SFXSlider");
        this.ambientSlider = Entity::findByName("AmbientSlider");

        // Find tabs
        this.settingsTabs = Entity::findByName("SettingsTabs");

        // Initial panel state
        Entity::setActive(this.settingsPanel, false);
        Entity::setActive(this.fadeOverlay, false);

        // Disable Continue and Load buttons (no save system yet)
        UI::setButtonInteractable(this.continueBtn, false);
        UI::setButtonInteractable(this.loadGameBtn, false);

        // Load saved audio settings and apply
        this.loadAudioSettings();

        // Start menu music
        if (Entity::isValid(this.menuMusic)) {
            Audio::setLoop(this.menuMusic, true);
            Audio::play2d(this.menuMusic);
        }

        Log::info("Main menu initialized");
    }

    public function onUpdate(float deltaTime): void {
        // ESC key handling could go here for pause menu in future
    }

    public function onDestroy(): void {
    }

    // ============================================
    // IUIButtonListener
    // ============================================

    @Override
    public function onButtonClicked(int buttonEntityId, String entityName): void {
        if (this.isTransitioning) {
            return;
        }

        this.playClickSound();

        if (entityName == "NewGameBtn") {
            this.startNewGame();
        } else if (entityName == "SettingsBtn") {
            this.showSettings();
        } else if (entityName == "BackBtn") {
            this.hideSettings();
        } else if (entityName == "ExitBtn") {
            Log::info("Exit requested - quit API not yet available");
        } else if (entityName == "AudioTabBtn") {
            UI::setTabsActiveIndex(this.settingsTabs, 0);
        } else if (entityName == "GraphicsTabBtn") {
            UI::setTabsActiveIndex(this.settingsTabs, 1);
        } else if (entityName == "ControlsTabBtn") {
            UI::setTabsActiveIndex(this.settingsTabs, 2);
        }
    }

    @Override
    public function onButtonPressed(int buttonEntityId, String entityName): void {
    }

    @Override
    public function onButtonReleased(int buttonEntityId, String entityName): void {
    }

    @Override
    public function onButtonHoverEnter(int buttonEntityId, String entityName): void {
    }

    @Override
    public function onButtonHoverExit(int buttonEntityId, String entityName): void {
    }

    // ============================================
    // IUISliderListener
    // ============================================

    @Override
    public function onSliderValueChanged(int entityId, String entityName, float newValue, float previousValue): void {
        if (entityName == "MasterSlider") {
            Audio::setBusVolume("Master", newValue);
            Config::setFloat("audio.masterVolume", newValue);
        } else if (entityName == "MusicSlider") {
            Audio::setBusVolume("Music", newValue);
            Config::setFloat("audio.musicVolume", newValue);
        } else if (entityName == "SFXSlider") {
            Audio::setBusVolume("SFX", newValue);
            Config::setFloat("audio.sfxVolume", newValue);
        } else if (entityName == "AmbientSlider") {
            Audio::setBusVolume("Ambient", newValue);
            Config::setFloat("audio.ambientVolume", newValue);
        }
    }

    @Override
    public function onSliderDragStart(int entityId, String entityName): void {
    }

    @Override
    public function onSliderDragEnd(int entityId, String entityName, float finalValue): void {
    }

    @Override
    public function onSliderHoverEnter(int entityId, String entityName): void {
    }

    @Override
    public function onSliderHoverExit(int entityId, String entityName): void {
    }

    // ============================================
    // Menu Actions
    // ============================================

    private function startNewGame(): void {
        this.isTransitioning = true;
        Log::info("Starting new game...");

        // Show fade overlay and let it animate, then load game scene
        Entity::setActive(this.fadeOverlay, true);
        this.fadeAndLoadGame();
    }

    private function async fadeAndLoadGame(): Promise<void> {
        // Wait for fade animation to complete
        await Timer.delay(1.5);
        Scene::load("scenes/Game.vfScene");
    }

    private function showSettings(): void {
        Entity::setActive(this.mainPanel, false);
        Entity::setActive(this.settingsPanel, true);
    }

    private function hideSettings(): void {
        Entity::setActive(this.settingsPanel, false);
        Entity::setActive(this.mainPanel, true);
    }

    private function playClickSound(): void {
        if (Entity::isValid(this.clickSfx)) {
            Audio::play2d(this.clickSfx);
        }
    }

    // ============================================
    // Audio Settings Persistence
    // ============================================

    private function loadAudioSettings(): void {
        float masterVol = Config::getFloat("audio.masterVolume", 1.0);
        float musicVol = Config::getFloat("audio.musicVolume", 0.7);
        float sfxVol = Config::getFloat("audio.sfxVolume", 1.0);
        float ambientVol = Config::getFloat("audio.ambientVolume", 0.5);

        // Apply to audio buses
        Audio::setBusVolume("Master", masterVol);
        Audio::setBusVolume("Music", musicVol);
        Audio::setBusVolume("SFX", sfxVol);
        Audio::setBusVolume("Ambient", ambientVol);

        // Apply to sliders
        if (Entity::isValid(this.masterSlider)) {
            UI::setSliderValue(this.masterSlider, masterVol);
        }
        if (Entity::isValid(this.musicSlider)) {
            UI::setSliderValue(this.musicSlider, musicVol);
        }
        if (Entity::isValid(this.sfxSlider)) {
            UI::setSliderValue(this.sfxSlider, sfxVol);
        }
        if (Entity::isValid(this.ambientSlider)) {
            UI::setSliderValue(this.ambientSlider, ambientVol);
        }
    }
}
