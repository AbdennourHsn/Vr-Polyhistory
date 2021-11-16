using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeleporControlle : MonoBehaviour
{
    private Camera camera;

    private void Start()
    {
        camera = FindObjectOfType<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        if (camera.transform.position.z > this.transform.position.z + 10) this.gameObject.SetActive(false);
    }
}
