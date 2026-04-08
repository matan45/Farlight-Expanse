import * from "engine/Log.mt";
import * from "engine/Entity.mt";
import * from "../../lib/math/Vec3f.mt";

@Script
public class CameraOrbitController {
    private int selfId;
    private float angle;
    private float orbitRadius;
    private float orbitHeight;
    private float orbitSpeed;

    public function onStart(): void {
        this.selfId = Entity::self();
        this.angle = 0.0;
        this.orbitRadius = 50.0;
        this.orbitHeight = 15.0;
        this.orbitSpeed = 0.05;

        float x = this.orbitRadius * cos(this.angle);
        float z = this.orbitRadius * sin(this.angle);
        Entity::setPosition(this.selfId, new Vec3f(x, this.orbitHeight, z));
    }

    public function onUpdate(float deltaTime): void {
        this.angle = this.angle + this.orbitSpeed * deltaTime;
        if (this.angle > 6.28318) {
            this.angle = this.angle - 6.28318;
        }

        float x = this.orbitRadius * cos(this.angle);
        float z = this.orbitRadius * sin(this.angle);
        Entity::setPosition(this.selfId, new Vec3f(x, this.orbitHeight, z));

        float yaw = -this.angle * 57.2958 + 90.0;
        Entity::setRotation(this.selfId, new Vec3f(-10.0, yaw, 0.0));
    }

    public function onDestroy(): void {
    }
}
