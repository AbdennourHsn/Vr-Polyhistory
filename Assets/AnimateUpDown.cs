using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimateUpDown : MonoBehaviour
{
    Vector3 PosIni;
    public float UpValue;
    public float DownValue;
    bool up;
    float y;
    private void Start()
    {
        PosIni = this.transform.position;
        y = PosIni.y;
    }
    // Update is called once per frame
    void Update()
    {
        if (!up) y += (0.7f * Time.deltaTime);
        else y -= (0.7f * Time.deltaTime);

        transform.position = new Vector3(PosIni.x,y,PosIni.z);

        if(y>=PosIni.y+UpValue) up=true;
        if (y <= PosIni.y) up = false;
    }
}
