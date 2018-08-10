local origCanTrain = MartianUniversity.CanTrain
function MartianUniversity:CanTrain(unit)
    if not unit.traits.Idiot and not unit.traits["Middle Aged"] then
        return origCanTrain(self, unit)
    end
end