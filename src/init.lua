--!strict
-- Automatically triggers the dialogue server when the player touches a prompt region.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local CollectionService = game:GetService("CollectionService");
local Players = game:GetService("Players");

local packages = script.Parent.roblox_packages;
local DialogueMakerTypes = require(packages.dialogue_maker_types);

type Client = DialogueMakerTypes.Client;
type Conversation = DialogueMakerTypes.Conversation;

return function(client: Client)

  for _, conversationModuleScript in CollectionService:GetTagged("DialogueMaker_Conversation") do

    local didInitialize, errorMessage = pcall(function()

      -- We're using pcall because require can throw an error if the module is invalid.
      local conversation = require(conversationModuleScript) :: Conversation;
      local conversationSettings = conversation:getSettings();
      local promptRegionPart = conversationSettings.promptRegion.basePart;
      if promptRegionPart then

        promptRegionPart.Touched:Connect(function(part)

          -- Make sure our player touched it and not someone else
          local PlayerFromCharacter = Players:GetPlayerFromCharacter(part.Parent);
          if PlayerFromCharacter == Players.LocalPlayer and client:getDialogue() == nil then

            local dialogue = conversation:findNextVerifiedDialogue();
            client:setDialogue(dialogue);

          end;

        end);

      end;

    end);

    if not didInitialize then

      local fullName = conversationModuleScript:GetFullName();
      warn(`[Dialogue Maker] Failed to initialize prompt region for {fullName}: {errorMessage}`);

    end;

  end;

end;