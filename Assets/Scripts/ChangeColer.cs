using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeColer : MonoBehaviour
{
   public void ChangeColRed() {

        this.gameObject.GetComponent<MeshRenderer>().material.color = Color.red;
    }

    public void ChangeColerGreen()
    {
        this.gameObject.GetComponent<MeshRenderer>().material.color = Color.green;
    }

}
