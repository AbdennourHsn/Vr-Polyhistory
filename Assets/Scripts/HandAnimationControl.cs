using UnityEngine;
using UnityEngine.InputSystem;


public class HandAnimationControl : MonoBehaviour
{
    [SerializeField] Animator HandAnimator;
    [SerializeField] InputActionReference gripAction;
    [SerializeField] InputActionReference pinchAction;

    private void OnEnable()
    {
        gripAction.action.performed += GripAnimation;
        pinchAction.action.performed += PinchAnimation;
        Reset();
    }
    private void OnDisable()
    {
        gripAction.action.performed -= GripAnimation;
        pinchAction.action.performed -= PinchAnimation;
        Reset();
    }

    private void PinchAnimation(InputAction.CallbackContext obj)
    {
        HandAnimator.SetFloat("Trigger", obj.ReadValue<float>());
    }

    private void GripAnimation(InputAction.CallbackContext obj)
    {
        HandAnimator.SetFloat("Grip", obj.ReadValue<float>());
    }

    public void Reset()
    {
        HandAnimator.SetFloat("Trigger", 0);
        HandAnimator.SetFloat("Grip", 0);
    }


}
