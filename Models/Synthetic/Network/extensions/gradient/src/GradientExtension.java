package org.nlogo.extensions.gradient;

import org.nlogo.api.DefaultClassManager;
import org.nlogo.api.PrimitiveManager;

public class GradientExtension extends DefaultClassManager {
    public void load(PrimitiveManager primitiveManager) {
        primitiveManager.addPrimitive ("scale", new Scale());
    }
}
