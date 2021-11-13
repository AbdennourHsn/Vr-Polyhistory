using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorControl : MonoBehaviour
{
    Vector3 startScal;
    private void Start()
    {
        startScal = this.transform.localScale;
    }
    public void OpenDoor()
    {
        LeanTween.scale(this.gameObject, new Vector3(startScal.x, startScal.y, 0), 1.5f);
    }
}
